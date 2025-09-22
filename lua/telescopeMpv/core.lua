local job_ok, job_lib = pcall(require, 'plenary.job')
if not job_ok then
  vim.schedule(function() vim.notify('[YT DEBUG] Falta plenary.nvim', vim.log.levels.ERROR) end)
  return
end

local M = {}
local player_state = {
  playing=false, jobid=nil, title=nil, paused=false, timing="", percent=0, muted=false, loaded=false,
  _cur=0, _dur=0
}
local player_ui = { buf=nil, win=nil, ns=vim.api.nvim_create_namespace("mpv") }
local player_conf = { width=50, height=6, border='single' }
local win_opts = { relative='editor', style='minimal', border=player_conf.border, row=1, col=vim.o.columns-player_conf.width-2, height=player_conf.height, width=player_conf.width }
local queue = {}

local function buf_valid()
  return player_ui.buf and vim.api.nvim_buf_is_valid(player_ui.buf)
end

local function win_valid()
  return player_ui.win and vim.api.nvim_win_is_valid(player_ui.win)
end

local function refresh_screen()
  vim.schedule(function()
    if not player_state.loaded or not (buf_valid() and win_valid()) then
      return
    end

    vim.api.nvim_buf_set_lines(player_ui.buf, 0, -1, false, {})

    local display_title = player_state.title or (#queue > 0 and "Loading..." or 'Not Playing')
    vim.api.nvim_buf_set_lines(player_ui.buf, 0, 1, false, {display_title})
    vim.api.nvim_buf_add_highlight(player_ui.buf, player_ui.ns, "Title", 0, 0, -1)

    local timing_text = player_state.timing or "00:00:00 / 00:00:00"
    vim.api.nvim_buf_set_lines(player_ui.buf, 1, 2, false, {timing_text})
    vim.api.nvim_buf_add_highlight(player_ui.buf, player_ui.ns, "Number", 1, 0, -1)

    local bar_width = player_conf.width - 2
    local filled = math.floor((player_state.percent/100) * bar_width)
    local empty = bar_width - filled
    local progress_bar = "[" .. string.rep("█", filled) .. string.rep("░", empty) .. "]"
    vim.api.nvim_buf_set_lines(player_ui.buf, 2, 3, false, {progress_bar})
    vim.api.nvim_buf_add_highlight(player_ui.buf, player_ui.ns, "Function", 2, 0, -1)

    vim.api.nvim_buf_set_lines(player_ui.buf, 3, 4, false, {player_state.percent .. "%"})
    vim.api.nvim_buf_add_highlight(player_ui.buf, player_ui.ns, "Number", 3, 0, -1)

    local status = "▶ Playing"
    if player_state.paused then status = "⏸ Paused" end
    if player_state.muted then status = status .. " 🔇 Muted" end
    vim.api.nvim_buf_set_lines(player_ui.buf, 4, 5, false, {status})
    vim.api.nvim_buf_add_highlight(player_ui.buf, player_ui.ns, "String", 4, 0, -1)

    vim.api.nvim_buf_set_lines(player_ui.buf, 5, 6, false, {"[q]uit [p]ause [m]ute [</>]seek [+/-]vol"})
    vim.api.nvim_buf_add_highlight(player_ui.buf, player_ui.ns, "Comment", 5, 0, -1)
  end)
end

local function parse_mpv_output(data)
  if not data then return end
  
  for _, line in ipairs(data) do
    if line:match("A:%s+(%d+:%d+:%d+)%s*/%s*(%d+:%d+:%d+)%s*%((%d+)%%%)") then
      local current, total, percent = line:match("A:%s+(%d+:%d+:%d+)%s*/%s*(%d+:%d+:%d+)%s*%((%d+)%%%)")
      player_state.timing = current .. " / " .. total
      player_state.percent = tonumber(percent)
      refresh_screen()
      return
    end

    if line:match("Metadata:") then
      local title_match = line:match("title: (.*)") or line:match("Title: (.*)")
      if title_match and title_match ~= "" then
        player_state.title = title_match
        refresh_screen()
        return
      end
    end
  end
end


local function play_song(query, title)
  player_state.playing = true
  player_state.title = title or "Cargando: " .. (query:match("[^/]+$") or query:sub(1, 30))
  player_state.timing = "00:00:00 / 00:00:00"
  player_state.percent = 0
  player_state._cur, player_state._dur = 0, 0
  player_state.paused = false
  player_state.muted = false

  refresh_screen()

  if player_state.jobid then
    vim.fn.jobstop(player_state.jobid)
  end

  local args = {
    "--no-video",
    "--vo=null",
    "--audio-display=no",
    "--term-status-msg=A: ${time-pos} / ${duration} (${percent-pos}%)",
    "--msg-level=status=info",
    query,
  }

  local job_opts = {
    pty = true,
    on_stdout = vim.schedule_wrap(function(_, data)
      parse_mpv_output(data)
    end),
    on_stderr = vim.schedule_wrap(function(_, data)
      parse_mpv_output(data)
    end),
    on_exit = vim.schedule_wrap(function(_, exit_code, signal)
      vim.notify('[YT DEBUG] Job de mpv ha terminado con código: ' .. tostring(exit_code), vim.log.levels.INFO)
      player_state.playing = false
      player_state.jobid = nil
      player_state.title = "Not Playing"
      player_state.timing = ""
      player_state.percent = 0
      refresh_screen()

      if #queue > 0 then
        local next_song = table.remove(queue, 1)
        play_song(next_song.url, next_song.title)
      end
    end)
  }

  local jobid = vim.fn.jobstart({"mpv", unpack(args)}, job_opts)
  if jobid > 0 then
    player_state.jobid = jobid
    vim.notify('[YT DEBUG] Job de mpv iniciado con PID: ' .. tostring(player_state.jobid), vim.log.levels.INFO)
  else
    player_state.playing = false
    player_state.title = "Error al iniciar mpv"
    vim.notify('[YT DEBUG] Error al iniciar job de mpv', vim.log.levels.ERROR)
    refresh_screen()
  end
end

function M.toggle_player()
  -- Si la ventana ya está abierta, la cierra sin detener el reproductor
  if player_state.loaded and win_valid() then
    vim.api.nvim_win_close(player_ui.win, true)
    player_ui.win = nil
    player_state.loaded = false
    return
  end
  
  -- Si el job de mpv existe pero la ventana está cerrada, la vuelve a abrir
  if player_state.jobid and player_state.jobid > 0 and not win_valid() then
    player_ui.win = vim.api.nvim_open_win(player_ui.buf, true, win_opts)
    if win_valid() then
      player_state.loaded = true
      refresh_screen()
      return
    end
  end

  -- Si no hay job de mpv, crea uno nuevo y la ventana
  player_ui.buf = vim.api.nvim_create_buf(false, true)
  if not player_ui.buf then return end
  vim.bo[player_ui.buf].filetype = 'mpv'
  vim.bo[player_ui.buf].buftype = 'nofile'

  player_ui.win = vim.api.nvim_open_win(player_ui.buf, true, win_opts)
  if not win_valid() then return end

  player_state.loaded = true
  refresh_screen()

  local function map_cmd(key, cmd)
    vim.keymap.set('n', key, function()
      if player_state.jobid then
        vim.api.nvim_chan_send(player_state.jobid, cmd)
        if key == 'p' then player_state.paused = not player_state.paused end
        if key == 'm' then player_state.muted = not player_state.muted end
        refresh_screen()
      end
    end, { buffer = player_ui.buf, silent = true, nowait = true })
  end

  map_cmd('q', 'q\n')
  map_cmd('p', 'p\n')
  map_cmd('m', 'm\n')
  map_cmd('>', '>\n')
  map_cmd('<', '<\n')
  map_cmd('+', '0\n')
  map_cmd('-', '9\n')
end

local function play_youtube_query(query, title)
  if not player_state.loaded then
    M.toggle_player()
    vim.defer_fn(function()
      play_song(query, title)
    end, 200)
  else
    play_song(query, title)
  end
end

local function urlencode(url)
  return url:gsub("([^%w ])", function(c) return string.format("%%%02X", string.byte(c)) end):gsub(" ", "+")
end

local function api_call(cb)
  local url = "https://youtube.googleapis.com/youtube/v3/search?part=snippet&maxResults=25&q=" .. M.opts.query .. "&key=" .. M.opts.envar
  job_lib:new({
    command = "curl",
    args = { "-s", url, "-H", "Accept: application/json" },
    on_exit = vim.schedule_wrap(function(j, exit_code)
      if exit_code ~= 0 then
        vim.notify("Error de conexión: " .. tostring(exit_code), "error")
        return
      end
      local result = table.concat(j:result(), "\n")
      local ok, json = pcall(vim.fn.json_decode, result)
      if ok and json and json.items then
        local res = {}
        for _, value in ipairs(json.items) do
          if value.id and value.id.videoId then
            table.insert(res, {
              channel = value.snippet.channelTitle,
              title = value.snippet.title,
              videoId = value.id.videoId
            })
          end
        end
        M.opts.results = res
        cb()
      else
        vim.notify("Error en respuesta de YouTube", "error")
      end
    end),
  }):start()
end

local function make_picker()
  local finders = require('telescope.finders')
  local pickers = require('telescope.pickers')
  local conf = require('telescope.config').values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  
  pickers.new({}, {
    prompt_title = "YouTube Search: " .. M.opts.query,
    finder = finders.new_table {
      results = M.opts.results,
      entry_maker = function(entry)
        return {
          value = entry,
          ordinal = entry.title .. " " .. entry.channel,
          display = entry.title .. " (" .. entry.channel .. ")"
        }
      end
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry and entry.value and entry.value.videoId then
          local url = "https://www.youtube.com/watch?v=" .. entry.value.videoId
          play_youtube_query(url, entry.value.title)
        end
      end)
      return true
    end,
  }):find()
end

function M.setup(opts)
  M.opts = vim.tbl_extend('force', {
    envar = os.getenv("Youtube_API_KEY") or os.getenv("YT_API_KEY")
  }, opts or {})
end

function M.single()
  M.opts.query = vim.fn.input("Buscar YouTube: ")
  if M.opts.query == "" then return end
  M.opts.query = urlencode(M.opts.query)
  api_call(make_picker)
end

function M.playlist()
  local url = vim.fn.input("URL de playlist: ")
  if url == "" then return end
  play_youtube_query(url, "Playlist: " .. (url:match("[^/]+$") or url))
end

function M.stop()
  if player_state.jobid then
    vim.fn.jobstop(player_state.jobid)
    player_state.playing = false
    player_state.title = "Detenido"
    refresh_screen()
  end
end

function M.toggle_pause()
  if player_state.jobid then
    vim.api.nvim_chan_send(player_state.jobid, 'p\n')
  end
end

function M.toggle_mute()
  if player_state.jobid then
    vim.api.nvim_chan_send(player_state.jobid, 'm\n')
  end
end

function M.volume_up()
  if player_state.jobid then
    vim.api.nvim_chan_send(player_state.jobid, '0\n')
  end
end

function M.volume_down()
  if player_state.jobid then
    vim.api.nvim_chan_send(player_state.jobid, '9\n')
  end
end

vim.api.nvim_create_user_command('MpvToggle', M.toggle_player, { desc = "Toggles the music player." })

return M