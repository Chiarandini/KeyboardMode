# Japanese Mode for Neovim

A simple Neovim plugin that automatically switches between Japanese (Hiragana) and English keyboard layouts when entering and leaving insert mode.

## Features

- Toggle Japanese mode on/off
- Automatically switches to Hiragana when entering insert mode (when Japanese mode is enabled)
- Automatically switches back to English when leaving insert mode
- Ignores prompts and pickers (Telescope, etc.) to avoid input conflicts
- macOS only

## Requirements

- macOS
- [keyboardSwitcher](https://github.com/lutzifer/homebrew-tap) - A command-line tool for switching keyboard layouts

## Installation

### 1. Install keyboardSwitcher

```bash
brew install lutzifer/homebrew-tap/keyboardSwitcher
```

### 2. Install the plugin

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  -- Put your plugin files in ~/.config/nvim/lua/JapaneseTools.lua
  "Chiarandini/JapaneseTools",
  config = function()
    require("JapaneseTools").setup()
  end,
}
```


## Setup

Add to your Neovim configuration:

```lua
require("JapaneseTools").setup()

-- Create a keybinding to toggle Japanese mode
vim.keymap.set('n', '<leader>j', function()
  require('JapaneseTools').toggle()
end, { desc = 'Toggle Japanese mode' })
```

## Usage

1. Press your toggle keybinding (e.g., `<leader>j`) to enable Japanese mode
2. When you enter insert mode (`i`, `a`, `o`, etc.), the keyboard will automatically switch to Hiragana
3. When you leave insert mode (`<Esc>`), the keyboard will automatically switch back to English
4. Press the toggle again to disable Japanese mode

## Keyboard Layouts

The plugin switches between:
- **English**: "Canadian" (you can modify this in the code if you use a different English layout)
- **Japanese**: "Hiragana"

## Ignored Contexts

The plugin won't switch keyboards in these contexts to avoid conflicts:
- Telescope prompts
- Picker prompts (dressing.nvim)
- Notification windows
- Other prompt buffers

## Configuration

The plugin works out of the box, but you can modify the keyboard layout names in the code if needed:

```lua
local layout_map = {
  ['Japanese'] = 'Hiragana',        -- Change this if you use a different Japanese input method
  ['Canadian English'] = 'Canadian' -- Change this to match your English layout
}
```

## Troubleshooting

If the plugin reports that `keyboardSwitcher` is not found:

1. Make sure it's installed: `brew install lutzifer/homebrew-tap/keyboardSwitcher`
2. Check that it's in your PATH: `which keyboardSwitcher`
3. Restart Neovim after installation

## License

This plugin is provided as-is. Feel free to modify and distribute.
