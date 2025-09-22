local telescope_ok, telescope = pcall(require, 'telescope')
if not telescope_ok then
  vim.notify('[YT DEBUG] Falta telescope.nvim', vim.log.levels.ERROR)
  return
end

-- Aquí es donde se carga la lógica del plugin, usando el nuevo nombre de la carpeta
local M = require('telescopeMpv.core')

return telescope.register_extension {
  setup = function(user_opts, _)
    M.setup(user_opts)
  end,
  exports = {
    single = M.single,
    playlist = M.playlist,
    stop = M.stop,
    toggle = M.toggle_player,
    toggle_pause = M.toggle_pause,
    toggle_mute = M.toggle_mute,
    volume_up = M.volume_up,
    volume_down = M.volume_down
  }
}