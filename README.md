# 🌅 Twilight

**Twilight** is a Lua plugin for Neovim 0.5 that dims inactive portions of the code you're editing.

The plugin was heavily inspired by [Limelight](https://github.com/junegunn/limelight.vim),
but uses [TreeSitter](https://github.com/nvim-treesitter/nvim-treesitter) for better dimming.

Pairs well with [zen-mode](https://github.com/folke/zen-mode.nvim).

![image](https://user-images.githubusercontent.com/292349/125419804-051321c2-d040-41c8-93fc-834b5f1098e3.png)

## ⚡️ Requirements

- Neovim >= 0.5.0

## 📦 Installation

Install the plugin with your preferred package manager:

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua
use {
  "folke/twilight.nvim",
  config = function()
    require("twilight").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  end
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
" Vim Script
Plug 'folke/twilight.nvim'

lua << EOF
  require("twilight").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
EOF
```

## ⚙️ Configuration

Twilight comes with the following defaults:

```lua
{
  dimming = {
    alpha = 0.25, -- amount of dimming
    -- we try to get the foreground from the highlight groups or fallback color
    color = { "Normal", "#ffffff" },
    inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
  },
  context = 10, -- amount of lines we will try to show around the current line
  treesitter = true, -- use treesitter when available for the filetype
  -- treesitter is used to automatically expand the visible text,
  -- but you can further control the types of nodes that should always be fully expanded
  expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
    "function",
    "method",
    "table",
    "if_statement",
  },
  exclude = {}, -- exclude these filetypes
}
```

## 🚀 Usage

You can manually trigger **Twilight** using the commands:

- `Twilight`: toggle twilight
- `TwilightEnable`: enable twilight
- `TwilightDisable`: disable twilight

## 🧘 Zen Mode Integration

If you have [zen-mode](https://github.com/folke/zen-mode.nvim) installed, then **Twilight**
is activated automatically. Refer to the Zen Mode documentation to disable.
