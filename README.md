# KeyboardTools.nvim

A generalized Neovim plugin for automatic keyboard layout switching on macOS. Originally designed for Japanese input switching, now supports any keyboard layout available on your system.

## Features

- 🔄 **Automatic Layout Switching**: Automatically switches to your alternate keyboard layout when entering insert mode or search mode
- 🎛️ **Configurable Layouts**: Support for any keyboard layout available on your macOS system
- ✅ **Layout Validation**: Automatically validates that configured layouts are available on your system
- 🚫 **Smart Buffer Filtering**: Ignores certain buffer types (Telescope, Oil, etc.)
- 📡 **Status Integration**: Provides global variables for statusline integration

## Prerequisites

- macOS (required)
- [keyboardSwitcher](https://github.com/lutzifer/homebrew-tap) - Install with: `brew install lutzifer/homebrew-tap/keyboardSwitcher`

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  dir = "Chiarandini/KeyboardTools",
  config = function()
    require("KeyboardTools").setup({
      default_layout = "Canadian",    -- Your default keyboard layout
      alternate_layout = "Hiragana"   -- Layout to switch to in insert mode
    })
  end
}
```

## Configuration

The plugin accepts the following options:

```lua
require("KeyboardTools").setup({
  default_layout = "Canadian",      -- Default layout (fallback to first available)
  alternate_layout = "Hiragana"     -- Alternate layout (fallback to second available)
})
```

## Available Methods

### Core Functions

- `toggle()` - Toggle between default and alternate keyboard modes
- `enable()` - Enable alternate keyboard mode
- `disable()` - Disable alternate keyboard mode (return to default)
- `is_enabled()` - Check if alternate keyboard mode is currently enabled

### Layout Management

- `get_available_layouts()` - Get list of all available keyboard layouts
- `get_config()` - Get current plugin configuration
- `switch_to_layout(layout_name)` - Temporarily switch to a specific layout

## Keyboard Shortcuts

You can set up keyboard shortcuts to control the plugin:

```lua
-- Toggle keyboard mode
vim.keymap.set('n', '<leader>kt', function()
  require('KeyboardTools').toggle()
end, { desc = 'Toggle keyboard mode' })

-- Enable alternate layout
vim.keymap.set('n', '<leader>ke', function()
  require('KeyboardTools').enable()
end, { desc = 'Enable alternate keyboard' })

-- Disable alternate layout
vim.keymap.set('n', '<leader>kd', function()
  require('KeyboardTools').disable()
end, { desc = 'Disable alternate keyboard' })
```

## Status Line Integration

The plugin sets a global variable `vim.g.KeyboardMode` that you can use in your statusline:

```lua
-- Example for lualine
{
  function()
    return vim.g.KeyboardMode and "🌸" or "🔤"
  end
}

-- Example for heirline
{
  condition = function()
    return vim.g.KeyboardMode
  end,
  provider = "🌸",
}
```

## Events

The plugin triggers a `KeyboardModeChanged` User event when the keyboard mode changes:

```lua
vim.api.nvim_create_autocmd('User', {
  pattern = 'KeyboardModeChanged',
  callback = function()
    print('Keyboard mode changed!')
  end,
})
```

## Behavior

The plugin automatically:

1. **Insert Mode**: Switches to alternate layout when entering insert mode, back to default when leaving
2. **Search Mode**: Switches to alternate layout when entering search (`/`), back to default when leaving
3. **Buffer Filtering**: Ignores switching in special buffer types:
   - TelescopePrompt
   - DressingSelect/DressingInput
   - noice/notify/prompt
   - Oil

## Finding Available Layouts

To see what keyboard layouts are available on your system:

```bash
keyboardSwitcher list
```

Or from within the plugin:

```lua
local layouts = require('KeyboardTools').get_available_layouts()
vim.print(layouts)
```

## Testing

Run the test suite:

```bash
lua run_tests.lua
```

The plugin includes comprehensive tests covering:
- Setup with default and custom configurations
- Layout validation and fallbacks
- Toggle/enable/disable functionality
- Layout switching capabilities
- Error handling for invalid configurations

## Troubleshooting

### keyboardSwitcher not found
Install keyboardSwitcher: `brew install lutzifer/homebrew-tap/keyboardSwitcher`

### Layout not available
Check available layouts with `keyboardSwitcher list` and update your configuration accordingly.

### Not working on non-Mac systems
This plugin only was tested on macOS due to the keyboardSwitcher dependency.
