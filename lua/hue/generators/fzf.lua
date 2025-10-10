local M = {}

function M.generate(highlights, palette)
  local fg = highlights.Normal.fg or '#ffffff'
  local bg = highlights.Normal.bg or '#000000'

  -- Map palette colors to fzf color slots (ordered for consistency)
  local fzf_colors = {
    { 'fg', fg },
    { 'bg', bg },
    { 'hl', palette[4] or palette[12] or '#4fa6ed' },
    { 'fg+', fg },
    { 'bg+', palette[8] or bg },
    { 'hl+', palette[12] or palette[4] or '#4fa6ed' },
    { 'info', palette[6] or palette[14] or '#00ffff' },
    { 'border', palette[8] or '#808080' },
    { 'prompt', palette[2] or palette[10] or '#00ff00' },
    { 'pointer', palette[5] or palette[13] or '#ff00ff' },
    { 'marker', palette[3] or palette[11] or '#ffff00' },
    { 'spinner', palette[6] or palette[14] or '#00ffff' },
    { 'header', palette[4] or palette[12] or '#4fa6ed' },
    { 'gutter', bg },
  }

  -- Generate fzf config file format (plain text, no shell exports)
  local content = {}
  for _, pair in ipairs(fzf_colors) do
    table.insert(content, string.format('--color=%s:%s', pair[1], pair[2]))
  end

  -- NOTE: keep otherwise command line is incorrectly configured
  table.insert(content, '')

  return content
end

return M
