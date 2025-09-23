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

## Con lazy.nvim

```lua
{
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'TakeMichiks/Telescope-Mpv.nvim',
    },
    config = function()
        require('telescope').load_extension('telescopeMpv')
        
        vim.keymap.set('n', '<leader>ym', '<cmd>Take<cr>', { desc = "YouTube: Buscar" })
        vim.keymap.set('n', '<leader>yp', '<cmd>Takep<cr>', { desc = "YouTube: Playlist" })
        vim.keymap.set('n', '<leader>yt', '<cmd>MpvToggle<cr>', { desc = "Toggle Player" })
    end,
}
```
### Con packer.nvim
```
use {
    'nvim-telescope/telescope.nvim',
    requires = {
        'nvim-lua/plenary.nvim',
        'TakeMichiks/Telescope-Mpv.nvim'
    },
    config = function()
        require('telescope').load_extension('telescopeMpv')
    end
}
```

## ⚙️ Configuración

### Clave API de YouTube (Recomendado)

Para mejores resultados de búsqueda, configura una clave API de YouTube:

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un proyecto o selecciona uno existente
3. Habilita la API de datos de YouTube v3
4. Crea credenciales (API Key)
5. Agrega la clave a tu configuración:

## 🎯 Ejemplos de Uso

### Búsqueda Básica
1. Presiona `<leader>ym` (por defecto `\ym`)
2. Escribe el nombre de la canción que buscas
3. Selecciona de los resultados con Enter
4. ¡La música comenzará a reproducirse!

### Usar URL Directa
1. Presiona `<leader>yp`
2. Pega la URL de YouTube
3. El reproductor se abrirá automáticamente

## 🛠️ Solución de Problemas

### El plugin no se carga
- Verifica que telescope.nvim esté instalado correctamente
- Asegúrate de que plenary.nvim esté disponible
- Comprueba que el archivo esté en la ruta correcta

### No se reproducen videos
- Verifica que mpv esté instalado: `mpv --version`
- Comprueba tu conexión a internet
- Asegúrate de que la URL sea válida

### Sin resultados de búsqueda
- Configura tu clave API de YouTube
- Verifica tu conexión a internet
- Comprueba que curl esté instalado

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor:

1. Haz fork del proyecto
2. Crea una rama para tu característica (`git checkout -b feature/CaracteristicaIncreible`)
3. Confirma tus cambios (`git commit -m 'Agregar CaracteristicaIncreible'`)
4. Sube a la rama (`git push origin feature/CaracteristicaIncreible`)
5. Abre un Pull Request

## 📄 Licencia

Distribuido bajo la Licencia MIT. Ver `LICENSE` para más información.

## ⭐ Agradecimientos

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Por la increíble API de extensiones
- [mpv](https://mpv.io/) - Por el excelente reproductor multimedia
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - Por las utilidades de Lua
- [Mpv.nvim](https://github.com/tamton-aquib/mpv.nvim/tree/main) - inspiracion principal para wiget
- [telescope-youtube-mpv.nvim](https://github.com/4542elgh/telescope-youtube-mpv.nvim) - inspiracion para uso de telescope

## 🐛 Reportar Problemas

Si encuentras un error, por favor abre un issue con:
- Descripción del problema
- Pasos para reproducirlo
- Versión de Neovim
- Configuración relevante

---

¿Te gusta este plugin? ¡Dale una ⭐ en GitHub!
