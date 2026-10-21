local colorscheme = os.getenv('COLORSCHEME')
if colorscheme and colorscheme ~= '' then
  local ok, error_message = pcall(vim.cmd.colorscheme, colorscheme)
  if not ok then
    error(string.format('Could not load colorscheme %q: %s', colorscheme, error_message))
  end
end

local data = require('colorsync.color_data').capture()
local html = require('colorsync.report').generate(data, require('colorsync.generators'))
local output = os.getenv('OUTPUT')
if not output or output == '' then
  output = string.format('build/colorsync-%s.html', data.colorscheme)
end
output = vim.fn.fnamemodify(output, ':p')

vim.fn.mkdir(vim.fs.dirname(output), 'p')
vim.fn.writefile(vim.split(html, '\n', { plain = true }), output)
print('ColorSync report written to ' .. output)
