local M = {}

function M.generate(highlights, palette)
  local content = {}

  -- Start WezTerm configuration
  --FIXME: consider json instead of lua
  table.insert(content, 'local colors = {')

  -- Core colors
  if highlights.Normal.fg then
    table.insert(content, string.format("  foreground = '%s',", highlights.Normal.fg))
  end
  if highlights.Normal.bg then
    table.insert(content, string.format("  background = '%s',", highlights.Normal.bg))
  end
  if highlights.Cursor.fg then
    table.insert(content, string.format("  cursor_fg = '%s',", highlights.Cursor.fg))
  end
  if highlights.Cursor.bg then
    table.insert(content, string.format("  cursor_bg = '%s',", highlights.Cursor.bg))
  end
  if highlights.Visual.fg or highlights.Cursor.fg then
    table.insert(content, string.format("  selection_fg = '%s',", highlights.Visual.fg or highlights.Cursor.fg))
  end
  if highlights.Visual.bg or highlights.Cursor.bg then
    table.insert(content, string.format("  selection_bg = '%s',", highlights.Visual.bg or highlights.Cursor.bg))
  end

  -- ANSI colors (0-7)
  table.insert(content, '  ansi = {')
  for i = 0, 7 do
    if palette and palette[i] then
      local comma = i < 7 and ',' or ''
      table.insert(content, string.format("    '%s'%s", palette[i], comma))
    end
  end
  table.insert(content, '  },')

  -- Bright colors (8-15)
  table.insert(content, '  brights = {')
  for i = 8, 15 do
    if palette and palette[i] then
      local comma = i < 15 and ',' or ''
      table.insert(content, string.format("    '%s'%s", palette[i], comma))
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
