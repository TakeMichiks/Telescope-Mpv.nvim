# 🎵 Telescope-Mpv.nvim

Una extensión de Telescope para buscar y reproducir música de YouTube directamente desde Neovim usando mpv como reproductor.

## ✨ Características

- 🔍 Buscar música en YouTube usando la API v3
- 🎵 Reproducir música directamente con mpv
- 🎮 Interfaz de control integrada en Neovim
- 📱 Barra de progreso visual
- ⌨️ Controles de teclado intuitivos
- 🔇 Control de volumen y silencio

## 📋 Requisitos

- Neovim 0.7+
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [mpv](https://mpv.io/) instalado en el sistema
- Clave API de YouTube (opcional para funcionalidad completa)

## 📦 Instalación

### Con lazy.nvim

{
'nvim-telescope/telescope.nv
m', tag =
0.1.6', depe
dencies = { 'nvi
-lua/plenary.nvim', 'Take
ic
iks/Telescope-Mpv.n

text
    telescope.setup({
        extensions = {
            telescopeMpv = {
                -- Configuración opcional
            }
        }
    })
    
    -- Cargar la extensión
    telescope.load_extension('telescopeMpv')
    
    -- Mapas de teclas
    vim.keymap.set('n', '<leader>ym', '<cmd>Take<cr>', { desc = "YouTube: Buscar canción" })
    vim.keymap.set('n', '<leader>yp', '<cmd>Takep<cr>', { desc = "YouTube: Buscar playlist" })
    vim.keymap.set('n', '<leader>yt', '<cmd>MpvToggle<cr>', { desc = "YouTube: Reproductor alternativo" })
end,
}

text

### Con packer.nvim

use {
'nvim-telescope/telescope.nv
m', requ
res = { 'nvim-lu
/plenary.nvim', 'TakeMic
ik
/Telescope-Mpv.nvim
}, config = function() require('te
esc

text

## ⚙️ Configuración

### Clave API de YouTube (Recomendado)

Para mejores resultados de búsqueda, configura una clave API de YouTube:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un proyecto o selecciona uno existente
3. Habilita la API de datos de YouTube v3
4. Crea credenciales (API Key)
5. Agrega la clave a tu configuración:
