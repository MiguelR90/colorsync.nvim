local M = {}

function M.generate(highlights, palette)
  local content = {}

  -- Palette colors (0-15)
  for i = 0, 15 do
    if palette.palette and palette.palette[i] then
      table.insert(content, string.format('palette = %d=%s', i, palette.palette[i]))
    end
  end

  -- Core colors
  if highlights.Normal.bg then
    table.insert(content, string.format('background = %s', highlights.Normal.bg))
  end
  if highlights.Normal.fg then
    table.insert(content, string.format('foreground = %s', highlights.Normal.fg))
  end
  if highlights.Cursor.bg then
    table.insert(content, string.format('cursor-color = %s', highlights.Cursor.bg))
  end
  if highlights.Cursor.fg then
    table.insert(content, string.format('cursor-text = %s', highlights.Cursor.fg))
  end
  if highlights.Visual.bg then
    table.insert(content, string.format('selection-background = %s', highlights.Visual.bg))
  end
  if highlights.Visual.fg then
    table.insert(content, string.format('selection-foreground = %s', highlights.Visual.fg))
  end

  -- NOTE: keep it's good practice
  table.insert(content, '')

  return content
end

return M
