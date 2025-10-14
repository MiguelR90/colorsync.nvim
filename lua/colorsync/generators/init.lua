local M = {}

-- TODO: consider dynamic require for all available tools
M.fzf = require('colorsync.generators.fzf')
M.ghostty = require('colorsync.generators.ghostty')
M.lazygit = require('colorsync.generators.lazygit')
M.tmtheme = require('colorsync.generators.tmtheme')

return M
