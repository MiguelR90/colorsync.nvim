local M = {}

local ANSI_NAMES = {
  [0] = 'Black',
  [1] = 'Red',
  [2] = 'Green',
  [3] = 'Yellow',
  [4] = 'Blue',
  [5] = 'Magenta',
  [6] = 'Cyan',
  [7] = 'White',
  [8] = 'Bright black',
  [9] = 'Bright red',
  [10] = 'Bright green',
  [11] = 'Bright yellow',
  [12] = 'Bright blue',
  [13] = 'Bright magenta',
  [14] = 'Bright cyan',
  [15] = 'Bright white',
}

function M.to_hex(color)
  if type(color) == 'string' then
    if color:match('^#%x%x%x%x%x%x$') then
      return color:lower()
    end

    local red, green, blue = color:match('^#(%x)(%x)(%x)$')
    if red then
      return string.format('#%s%s%s%s%s%s', red, red, green, green, blue, blue):lower()
    end

    local r, g, b = color:match('^rgb%((%d+),%s*(%d+),%s*(%d+)%)$')
    if r then
      return string.format('#%02x%02x%02x', tonumber(r), tonumber(g), tonumber(b))
    end

    return color
  elseif type(color) == 'number' then
    return string.format('#%06x', color)
  end

  return color
end

local function normalize_attributes(attributes)
  local normalized = {}
  for key, value in pairs(attributes or {}) do
    if key == 'fg' or key == 'bg' or key == 'sp' then
      normalized[key] = M.to_hex(value) or value
    else
      normalized[key] = value
    end
  end
  return normalized
end

local function capture_highlights()
  local resolved = {}
  local definitions = {}
  local names = vim.fn.getcompletion('', 'highlight')
  table.sort(names)

  for _, name in ipairs(names) do
    resolved[name] = normalize_attributes(vim.api.nvim_get_hl(0, { name = name, link = false }))
    definitions[name] = normalize_attributes(vim.api.nvim_get_hl(0, { name = name, link = true }))
  end

  return resolved, definitions, names
end

local function capture_terminal_palette()
  local palette = {}
  local sources = {}

  for index = 0, 15 do
    local global_name = 'terminal_color_' .. index
    local color = M.to_hex(vim.g[global_name])
    if color then
      palette[index] = color
      sources[index] = {
        kind = 'terminal',
        label = global_name,
        description = ANSI_NAMES[index],
      }
    else
      sources[index] = {
        kind = 'unset',
        label = 'unset',
        description = ANSI_NAMES[index],
      }
    end
  end

  return palette, sources
end

function M.capture()
  local highlights, definitions, names = capture_highlights()
  local terminal_palette, terminal_sources = capture_terminal_palette()

  return {
    colorscheme = vim.g.colors_name or 'default',
    highlights = highlights,
    highlight_definitions = definitions,
    highlight_names = names,
    terminal_palette = terminal_palette,
    terminal_sources = terminal_sources,
  }
end

return M
