local M = {}

function M.describe(highlights, terminal_palette)
  local map = require('colorsync.mapping')
  highlights = highlights or {}
  terminal_palette = terminal_palette or {}
  local mappings = {
    map.entry('foreground', 'terminal foreground', { map.highlight(highlights, 'Normal', 'fg') }),
    map.entry('background', 'terminal background', { map.highlight(highlights, 'Normal', 'bg') }),
    map.entry('cursor_fg', 'cursor text', { map.highlight(highlights, 'Cursor', 'fg') }),
    map.entry('cursor_bg', 'cursor background', { map.highlight(highlights, 'Cursor', 'bg') }),
    map.entry('selection_fg', 'selection text', {
      map.highlight(highlights, 'Visual', 'fg'),
      map.highlight(highlights, 'Cursor', 'fg'),
    }),
    map.entry('selection_bg', 'selection background', {
      map.highlight(highlights, 'Visual', 'bg'),
      map.highlight(highlights, 'Cursor', 'bg'),
    }),
  }

  for index = 0, 15 do
    table.insert(
      mappings,
      map.entry(
        index < 8 and string.format('ansi[%d]', index) or string.format('brights[%d]', index - 8),
        'ANSI terminal color',
        { map.terminal(terminal_palette, index) }
      )
    )
  end

  return mappings
end

function M.generate(highlights, terminal_palette)
  local content = {}
  local mappings = M.describe(highlights, terminal_palette)
  local by_target = {}
  for _, mapping in ipairs(mappings) do
    by_target[mapping.target] = mapping
  end

  -- Start WezTerm configuration
  --FIXME: consider json instead of lua
  table.insert(content, 'local colors = {')

  -- Core colors
  for _, target in ipairs({ 'foreground', 'background', 'cursor_fg', 'cursor_bg', 'selection_fg', 'selection_bg' }) do
    local mapping = by_target[target]
    if mapping.value then
      table.insert(content, string.format("  %s = '%s',", target, mapping.value))
    end
  end

  -- ANSI colors (0-7)
  table.insert(content, '  ansi = {')
  for i = 0, 7 do
    local value = by_target[string.format('ansi[%d]', i)].value
    if value then
      local comma = i < 7 and ',' or ''
      table.insert(content, string.format("    '%s'%s", value, comma))
    end
  end
  table.insert(content, '  },')

  -- Bright colors (8-15)
  table.insert(content, '  brights = {')
  for i = 8, 15 do
    local value = by_target[string.format('brights[%d]', i - 8)].value
    if value then
      local comma = i < 15 and ',' or ''
      table.insert(content, string.format("    '%s'%s", value, comma))
    end
  end
  table.insert(content, '  },')

  -- Close the configuration
  table.insert(content, '}')

  table.insert(content, '')
  table.insert(content, 'return colors')
  table.insert(content, '')

  return content
end

return M
