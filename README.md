# colorsync.nvim

`colorsync.nvim` extends your Neovim colorscheme across your entire development environment.

## Features

- Sync colorschemes with external tools
- Simple and lightweight with minimal overhead
- Default integration with popular tools 
- Native API (i.e. :colorscheme tokyonight just works)

## Supported Tools

- **Ghostty** - Terminal emulator 
- **fzf** - Fuzzy finder 
- _(More coming soon)_

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "MiguelR90/colorsync.nvim",
  config = function()
    require("colorsync").setup({
      -- your configuration here
    })
  end
}
```

## Usage

### Basic Usage

After installation, `colorsync.nvim` will automatically sync your colorscheme changes:

```lua
-- Change colorscheme as usual
vim.cmd.colorscheme("tokyonight")
-- colorsync automatically updates your tools
```

### Manual Sync

You can manually trigger synchronization:

```lua
require("colorsync").sync()
```

## Configuration

```lua
require("colorsync").setup({
  -- Placeholder config

  -- Enable/disable specific integrations
  integrations = {
    fzf = true,
    ghostty = true,
  },
  
  -- Auto-sync on colorscheme change
  auto_sync = true,
  
  -- Show notifications when syncing
  notify = true,
})
```

## How It Works

`colorsync.nvim` extracts color values from your active Neovim colorscheme and translates them into configuration formats compatible with each supported tool. When you change your Neovim colorscheme, it automatically updates configuration files or applies themes in real-time.

