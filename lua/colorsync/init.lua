local M = {}

function M.sync()
  local color_data = require('colorsync.color_data').capture()
  local generators = require('colorsync.generators')

  local config_dir = vim.fs.dirname(vim.fn.stdpath('config'))
  local colorsync_dir = vim.fs.joinpath(config_dir, 'colorsync')
  vim.fn.mkdir(colorsync_dir, 'p')

  for name, gen in pairs(generators) do
    local path = vim.fs.joinpath(colorsync_dir, name)
    local content = gen.generate(color_data.highlights, color_data.terminal_palette)
    vim.fn.writefile(content, path)
  end

  --FIXME: Reloading ghostty should go somewhere else
  vim.system({
    'osascript',
    '-e',
    [[
    tell application "System Events"
        tell process "ghostty"
            keystroke "r" using {command down}
        end tell
    end tell
    ]],
  })
end

function M.create_commands(_)
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('ColorSyncAuGroup', { clear = true }),
    callback = M.sync,
  })
end

function M.setup(opts)
  M.create_commands(opts)
  vim.cmd('colorscheme ' .. opts.colorscheme)
end

return M
