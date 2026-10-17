local M = {}

function M.generate(highlights, palette)
  local content = {}
  highlights = highlights or {}
  palette = palette or {}

  -- Start YAML structure
  table.insert(content, 'gui:')
  table.insert(content, '  theme:')

  -- Helper function to format color entry
  local function add_entry(name, color, modifiers)
    if color then
      table.insert(content, string.format('    %s:', name))
      table.insert(content, string.format('      - "%s"', color))
      for _, modifier in ipairs(modifiers or {}) do
        table.insert(content, string.format('      - %s', modifier))
      end
      table.insert(content, '') -- split with new lines
    end
  end

  local function hl(name, attr)
    return highlights[name] and highlights[name][attr]
  end

  local function first(...)
    for i = 1, select('#', ...) do
      local value = select(i, ...)
      if value then
        return value
      end
    end
  end

  local function parse_hex(color)
    local hex = type(color) == 'string' and color:match('^#(%x%x%x%x%x%x)$')
    if not hex then
      return nil
    end

    return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
  end

  local function relative_luminance(color)
    local red, green, blue = parse_hex(color)
    if not red then
      return nil
    end

    local function linearize(channel)
      channel = channel / 255
      return channel <= 0.04045 and channel / 12.92 or ((channel + 0.055) / 1.055) ^ 2.4
    end

    red = linearize(red)
    green = linearize(green)
    blue = linearize(blue)
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue
  end

  local function contrast_ratio(first_color, second_color)
    local first_luminance = relative_luminance(first_color)
    local second_luminance = relative_luminance(second_color)
    if not first_luminance or not second_luminance then
      return 0
    end

    local lighter = math.max(first_luminance, second_luminance)
    local darker = math.min(first_luminance, second_luminance)
    return (lighter + 0.05) / (darker + 0.05)
  end

  local default_fg = first(hl('Normal', 'fg'), palette[7], palette[15])
  local default_bg = first(hl('Normal', 'bg'), palette[0])

  local function contrasting_text(background)
    local foreground_ratio = contrast_ratio(background, default_fg)
    local background_ratio = contrast_ratio(background, default_bg)
    return background_ratio > foreground_ratio and default_bg or default_fg
  end

  local roles = {
    accent = first(
      hl('DiagnosticInfo', 'fg'),
      hl('Title', 'fg'),
      hl('@function', 'fg'),
      hl('Function', 'fg'),
      palette[4],
      palette[12]
    ),
    muted = first(
      hl('FloatBorder', 'fg'),
      hl('WinSeparator', 'fg'),
      hl('Comment', 'fg'),
      hl('NonText', 'fg'),
      palette[8]
    ),
    search = first(
      hl('IncSearch', 'bg'),
      hl('Search', 'bg'),
      hl('IncSearch', 'fg'),
      hl('Search', 'fg'),
      palette[6],
      palette[14]
    ),
    options = first(default_fg, hl('StatusLine', 'fg'), hl('@type', 'fg'), hl('Type', 'fg'), palette[4], palette[12]),
    selection = first(hl('Visual', 'bg'), hl('PmenuSel', 'bg'), hl('CursorLine', 'bg'), palette[8]),
    inactive_selection = 'default',
    success = first(hl('DiffAdd', 'bg'), hl('DiagnosticOk', 'fg'), hl('String', 'fg'), palette[2], palette[10]),
    warning = first(
      hl('DiagnosticWarn', 'fg'),
      hl('WarningMsg', 'fg'),
      hl('DiffChange', 'bg'),
      palette[3],
      palette[11]
    ),
    error = first(hl('DiagnosticError', 'fg'), hl('DiffDelete', 'fg'), hl('ErrorMsg', 'fg'), palette[1], palette[9]),
  }

  add_entry('activeBorderColor', roles.accent, { 'bold' })
  add_entry('inactiveBorderColor', roles.muted)
  add_entry('searchingActiveBorderColor', roles.search, { 'bold' })
  add_entry('optionsTextColor', roles.options)

  -- selectedLineFgColor: selected line foreground and attributes.
  -- "default" preserves the existing text colors while disabling Lazygit's default bold style.
  local selected_fg = highlights.Visual and highlights.Visual.fg or 'default'
  local selected_modifiers = {}
  for _, modifier in ipairs({ 'bold', 'reverse', 'underline', 'strikethrough' }) do
    if highlights.Visual and highlights.Visual[modifier] then
      table.insert(selected_modifiers, modifier)
    end
  end
  add_entry('selectedLineFgColor', selected_fg, selected_modifiers)
  add_entry('selectedLineBgColor', roles.selection)
  add_entry('inactiveViewSelectedLineBgColor', roles.inactive_selection)

  add_entry('cherryPickedCommitFgColor', contrasting_text(roles.success))
  add_entry('cherryPickedCommitBgColor', roles.success)
  add_entry('markedBaseCommitFgColor', contrasting_text(roles.warning))
  add_entry('markedBaseCommitBgColor', roles.warning)
  add_entry('unstagedChangesColor', roles.error)
  add_entry('defaultFgColor', default_fg)

  return content
end

return M
