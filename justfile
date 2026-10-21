default:
    @just --list



# Interactive Neovim colorscheme selector using fzf
switch-colorscheme:
    @nvim --headless +'luafile scripts/switch-colorscheme.lua' +qa! 2>&1 | grep -v "ColorScheme synced"

# Generate a standalone visual report for an installed Neovim colorscheme
color-report colorscheme="everforest" output="":
    @COLORSCHEME="{{colorscheme}}" OUTPUT="{{output}}" nvim --headless +'set runtimepath^=.' +'luafile scripts/generate-color-report.lua' +qa!
