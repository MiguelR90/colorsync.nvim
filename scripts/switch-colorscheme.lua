-- Get all available colorschemes
local colors = vim.fn.getcompletion('', 'color')

-- Convert to newline-separated string for fzf
local input = table.concat(colors, '\n')

-- Launch fzf for selection
local fzf_cmd = { 'fzf', '--prompt=Pick colorscheme: ', '--height=75%', '--reverse' }
local result = vim.system(fzf_cmd, { stdin = input, text = true }):wait()

local colorscheme = result.stdout and vim.trim(result.stdout) or nil

-- Apply the selected theme
if colorscheme and colorscheme ~= '' then
  print('Applying colorscheme: ' .. colorscheme)
  vim.cmd('colorscheme ' .. colorscheme)
  -- Call sync function
  if pcall(require, 'hue') then
    require('hue').sync()
  end
  print('✓ Colorscheme applied and tools synced')
else
  print('No colorscheme selected.')
end
