default:
    @just --list



# Interactive Neovim colorscheme selector using fzf
switch-colorscheme:
    @nvim --headless +'luafile scripts/switch-colorscheme.lua' +qa! 2>&1 | grep -v "ColorScheme synced"
