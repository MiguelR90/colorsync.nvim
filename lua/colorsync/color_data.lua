local M = {}

local ANSI_COLOR_MAP = {
  [0] = { groups = { 'Normal' }, attr = 'bg', description = 'Black / background' },
  [1] = { groups = { 'ErrorMsg', 'DiffDelete', 'DiagnosticError' }, attr = 'fg', description = 'Red' },
  [2] = { groups = { 'String', 'DiffAdd', 'DiagnosticOk' }, attr = 'fg', description = 'Green' },
  [3] = { groups = { 'WarningMsg', 'DiffChange', 'DiagnosticWarn' }, attr = 'fg', description = 'Yellow' },
  [4] = { groups = { 'Function', 'Statement', 'DiagnosticInfo' }, attr = 'fg', description = 'Blue' },
  [5] = { groups = { 'Keyword', 'Type', 'PreProc' }, attr = 'fg', description = 'Magenta' },
  [6] = { groups = { 'Special', 'Identifier', 'DiagnosticHint' }, attr = 'fg', description = 'Cyan' },
  [7] = { groups = { 'Normal' }, attr = 'fg', description = 'White / foreground' },
  [8] = { groups = { 'Comment', 'LineNr', 'NonText' }, attr = 'fg', description = 'Bright black / gray' },
  [9] = { groups = { 'ErrorMsg', 'DiffDelete' }, attr = 'fg', description = 'Bright red' },
  [10] = { groups = { 'String', 'DiffAdd' }, attr = 'fg', description = 'Bright green' },
  [11] = { groups = { 'WarningMsg', 'Number' }, attr = 'fg', description = 'Bright yellow' },
  [12] = { groups = { 'Function', 'Identifier' }, attr = 'fg', description = 'Bright blue' },
  [13] = { groups = { 'Keyword', 'Constant' }, attr = 'fg', description = 'Bright magenta' },
  [14] = { groups = { 'Special', 'Type' }, attr = 'fg', description = 'Bright cyan' },
  [15] = { groups = { 'Normal', 'NormalFloat' }, attr = 'fg', description = 'Bright white' },
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

local function capture_terminal_palette(highlights)
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
        description = ANSI_COLOR_MAP[index].description,
      }
    else
      local fallback = ANSI_COLOR_MAP[index]
      for _, group in ipairs(fallback.groups) do
        local value = highlights[group] and highlights[group][fallback.attr]
        if value then
          palette[index] = value
          sources[index] = {
            kind = 'highlight-fallback',
            label = string.format('%s.%s', group, fallback.attr),
            description = fallback.description,
          }
          break
        end
      end
    end

    if not sources[index] then
      sources[index] = {
        kind = 'unset',
        label = 'unset',
        description = ANSI_COLOR_MAP[index].description,
      }
    end
  end

  return palette, sources
end

function M.capture()
  local highlights, definitions, names = capture_highlights()
  local terminal_palette, terminal_sources = capture_terminal_palette(highlights)

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
