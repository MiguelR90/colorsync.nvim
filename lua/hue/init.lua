local M = {}

-- Convert various color formats (number, rgb(), hex) into lowercase #rrggbb
local function to_hex(color)
  if type(color) == 'string' then
    -- Handle hex string (#rrggbb or #RGB)
    if color:match('^#%x+$') then
      return color:lower()
    end
    -- Handle rgb(255, 0, 0) format
    local r, g, b = color:match('rgb%((%d+),%s*(%d+),%s*(%d+)%)')
    if r then
      return string.format('#%02x%02x%02x', tonumber(r), tonumber(g), tonumber(b))
    end
    vim.notify('Unsupported color str format: ' .. vim.inspect(color), vim.log.levels.WARN)
    return color
  elseif type(color) == 'number' then
    -- Handle Neovim numeric RGB format (e.g. 16711680)
    return string.format('#%06x', color)
  end
  return color
end

-- Get all highlight groups with resolved colors
local function get_highlights()
  local highlights = {}
  for _, name in ipairs(vim.fn.getcompletion('', 'highlight')) do
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    for k, v in pairs(hl) do
      hl[k] = to_hex(v) or v
    end
    highlights[name] = hl
  end
  return highlights
end

-- Get the palette from terminal colors (i.e., 16 ANSI colors)
local function get_palette()
  local palette = {}
  for i = 0, 15 do
    palette[i] = to_hex(vim.g['terminal_color_' .. i])
  end
  return palette
end

function M.sync()
  local highlights = get_highlights()
  local palette = get_palette()
  local generators = require('hue.generators')

  local config_dir = vim.fs.joinpath('/tmp', 'colors')
  vim.fn.mkdir(config_dir, 'p')

  for name, gen in pairs(generators) do
    local path = vim.fs.joinpath(config_dir, name)
    local content = gen.generate(highlights, palette)
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

function M.create_commands()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('HueSyncAuGroup', { clear = true }),
    callback = function(_)
      M.sync()
      vim.notify('ColorScheme synced by AutoCmd!', vim.log.levels.INFO)
    end,
  })
end

function M.setup()
  M.create_commands()
end

return M
