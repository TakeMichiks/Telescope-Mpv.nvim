# Telescopio-Mpv.nvim
Telescopio estatal para buscar música directamente desde la Api 3 de YouTube con Mpv de reproductor

# 🎵 Telescopio-Mpv.nvim

Una extensión de Telescope para buscar y reproducir música de YouTube directamente desde Neovim usando mpv como reproductor.

## ✨ Características

- 🔍 Buscar música en YouTube usando la API v3
- 🎵 Reproducir música directamente con mpv
- 🎮 Interfaz de control integrada en Neovim
- 📱 Barra de progreso visual
- ⌨️ Controles de teclado intuitivos
- 🔇 Control de volumen y silencio

## 📋 Requisitos

- Neovim 0,7+
- [telescopio.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [pleno.nvim](https://github.com/nvim-lua/plenary.nvim)
- [mpv](https://mpv.io/) instalado en el sistema
- Clave API de YouTube (opcional para funcionalidad completa)

## 📦 Instalación

### Con perezoso.nvim
{
'telescopio nvim/telescopio.nvim',
etiqueta = '0.1.6',
dependencias = {
'nvim-lua/plenary.nvim',
'TakeMichiks/Telescope-Mpv.nvim',
},
configuración = función()
telescopio local = require('telescopio')

texto
 telescopio.setup({
 extensiones = {
 telescopioMpv = {
 -- Configuración opcional
            }
        }
 })
    
    -- Carga la extensión
    telescopio.load_extension('telescopioMpv')
    
    -- Mapas de teclas
    vim.keymap.set('n', '<leader>ym', '<cmd>Take<cr>', { desc = "YouTube: Buscar canción" })
    vim.keymap.set('n', '<leader>yp', '<cmd>Takep<cr>', { desc = "YouTube: lista de reproducción de Buscar" })
    vim.keymap.set('n', '<leader>yt', '<cmd>MpvToggle<cr>', { desc = "YouTube: Reproductor alternativo" })
fin,
}

### Empaquetador de contenedores.nvim

usar {
'telescopio nvim/telescopio.nvim',
requiere = {
'nvim-lua/plenary.nvim',
'TakeMichiks/Telescope-Mpv.nvim'
},
configuración = función()
require('telescopio').load_extension('telescopioMpv')
fin
}

## ⚙️ Configuración

### API Key de YouTube (Recomendado)

Para mejores resultados de búsqueda, configura una API key de YouTube:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un proyecto o selecciona uno existente
3. Habilita la YouTube Data API v3
4. Crea credenciales (API Key)
5. Agrega la key a tu configuración:
