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
- **LazyGit** - Git terminal UI
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

### LazyGit

ColorSync writes the generated LazyGit theme to `~/.config/colorsync/lazygit`. Keep it separate from your
regular LazyGit settings and load both files with LazyGit's built-in config merging:

```sh
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml,$HOME/.config/colorsync/lazygit"
```

LazyGit merges the files from left to right, so the generated theme overrides theme values in the base
configuration without replacing unrelated settings.

#### Difftastic Colors

Difftastic chooses between regular and bright ANSI colors based on its `--background` option:

- `--background=light` uses regular red and green (ANSI slots 1 and 2).
- `--background=dark` uses bright red and green (ANSI slots 9 and 10).

Prefer `--background=light` with Everforest:

```yaml
git:
  diffRenderers:
    #NOTE: "light" selects regular ANSI red/green; it does not change the terminal background.
    - command: difft --color=always --background=light --display=inline --syntax-highlight=off
      type: extDiff
```

Everforest blends its bright ANSI colors toward the foreground, which produces pale red and green that can wash out Difftastic output. The `--background` option selects ANSI intensity; it does not change the terminal's actual background.

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

## Explore a Colorscheme

Generate a standalone HTML report for any installed colorscheme:

```sh
just color-report everforest
```

The report is written to `build/colorsync-everforest.html`. It explains and visualizes:

- resolved highlight groups and their links, colors, and modifiers;
- the separate 16-color ANSI terminal palette and where each value came from;
- every ColorSync integration target, its selected Neovim source, and its fallback chain.

Read the [ColorSync color model](docs/color-model.md) for diagrams and a complete walkthrough of the retrieval and mapping pipeline.

Pass a second argument to choose another output path:

```sh
just color-report tokyonight /tmp/tokyonight-colors.html
```
