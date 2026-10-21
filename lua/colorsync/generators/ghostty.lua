local M = {}

function M.describe(highlights, terminal_palette)
  local map = require('colorsync.mapping')
  highlights = highlights or {}
  terminal_palette = terminal_palette or {}
  local mappings = {}

  for index = 0, 15 do
    table.insert(
      mappings,
      map.entry('palette.' .. index, 'ANSI terminal color', { map.terminal(terminal_palette, index) })
    )
  end

  local fields = {
    { 'background', 'terminal background', 'Normal', 'bg' },
    { 'foreground', 'terminal foreground', 'Normal', 'fg' },
    { 'cursor-color', 'cursor background', 'Cursor', 'bg' },
    { 'cursor-text', 'cursor text', 'Cursor', 'fg' },
    { 'selection-background', 'selection background', 'Visual', 'bg' },
    { 'selection-foreground', 'selection text', 'Visual', 'fg' },
  }
  for _, field in ipairs(fields) do
    table.insert(mappings, map.entry(field[1], field[2], { map.highlight(highlights, field[3], field[4]) }))
  end

  return mappings
end

function M.generate(highlights, terminal_palette)
  local content = {}
  local mappings = M.describe(highlights, terminal_palette)

  for i = 0, 15 do
    local mapping = mappings[i + 1]
    if mapping.value then
      table.insert(content, string.format('palette = %d=%s', i, mapping.value))
    end
  end

  for index = 17, #mappings do
    local mapping = mappings[index]
    if mapping.value then
      table.insert(content, string.format('%s = %s', mapping.target, mapping.value))
    end
  end

  -- NOTE: keep it's good practice
  table.insert(content, '')

  return content
end

return M
