local M = {}

function M.describe(highlights, terminal_palette)
  local map = require('colorsync.mapping')
  highlights = highlights or {}
  terminal_palette = terminal_palette or {}

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

  local function hl(group, attribute)
    return map.highlight(highlights, group, attribute)
  end

  local function ansi(index)
    return map.terminal(terminal_palette, index)
  end

  local default_fg = map.entry('default foreground role', 'default foreground', {
    hl('Normal', 'fg'),
    ansi(7),
    ansi(15),
  })
  local default_bg = map.entry('default background role', 'default background', {
    hl('Normal', 'bg'),
    ansi(0),
  })

  local function contrasting_text(background)
    local foreground_ratio = contrast_ratio(background.value, default_fg.value)
    local background_ratio = contrast_ratio(background.value, default_bg.value)
    local selected = background_ratio > foreground_ratio and default_bg.selected or default_fg.selected
    return map.derived(
      selected and selected.value,
      string.format(
        'higher contrast of %s and %s against %s',
        default_fg.selected and default_fg.selected.label or 'unset foreground',
        default_bg.selected and default_bg.selected.label or 'unset background',
        background.selected and background.selected.label or 'unset'
      )
    )
  end

  local roles = {
    accent = map.entry('accent role', 'active accent', {
      hl('DiagnosticInfo', 'fg'),
      hl('Title', 'fg'),
      hl('@function', 'fg'),
      hl('Function', 'fg'),
      ansi(4),
      ansi(12),
    }),
    muted = map.entry('muted role', 'muted UI', {
      hl('FloatBorder', 'fg'),
      hl('WinSeparator', 'fg'),
      hl('Comment', 'fg'),
      hl('NonText', 'fg'),
      ansi(8),
    }),
    search = map.entry('search role', 'search emphasis', {
      hl('IncSearch', 'bg'),
      hl('Search', 'bg'),
      hl('IncSearch', 'fg'),
      hl('Search', 'fg'),
      ansi(6),
      ansi(14),
    }),
    options = map.entry('options role', 'option text', {
      map.derived(
        default_fg.value,
        default_fg.selected and default_fg.selected.label or 'default foreground unavailable'
      ),
      hl('StatusLine', 'fg'),
      hl('@type', 'fg'),
      hl('Type', 'fg'),
      ansi(4),
      ansi(12),
    }),
    selection = map.entry('selection role', 'active selection background', {
      hl('Visual', 'bg'),
      hl('PmenuSel', 'bg'),
      hl('CursorLine', 'bg'),
      ansi(8),
    }),
    inactive_selection = map.entry('inactive selection role', 'inactive selection background', {
      map.literal('default', 'Lazygit default color'),
    }),
    success = map.entry('success role', 'success background', {
      hl('DiffAdd', 'bg'),
      hl('DiagnosticOk', 'fg'),
      hl('String', 'fg'),
      ansi(2),
      ansi(10),
    }),
    warning = map.entry('warning role', 'warning background', {
      hl('DiagnosticWarn', 'fg'),
      hl('WarningMsg', 'fg'),
      hl('DiffChange', 'bg'),
      ansi(3),
      ansi(11),
    }),
    error = map.entry('error role', 'error text', {
      hl('DiagnosticError', 'fg'),
      hl('DiffDelete', 'fg'),
      hl('ErrorMsg', 'fg'),
      ansi(1),
      ansi(9),
    }),
  }

  local selected_modifiers = {}
  for _, modifier in ipairs({ 'bold', 'reverse', 'underline', 'strikethrough' }) do
    if highlights.Visual and highlights.Visual[modifier] then
      table.insert(selected_modifiers, modifier)
    end
  end

  return {
    map.entry('activeBorderColor', 'active panel border', roles.accent.candidates, { 'bold' }),
    map.entry('inactiveBorderColor', 'inactive panel border', roles.muted.candidates),
    map.entry('searchingActiveBorderColor', 'search panel border', roles.search.candidates, { 'bold' }),
    map.entry('optionsTextColor', 'option text', roles.options.candidates),
    map.entry('selectedLineFgColor', 'selected line text', {
      hl('Visual', 'fg'),
      map.literal('default', 'Lazygit default color'),
    }, selected_modifiers),
    map.entry('selectedLineBgColor', 'selected line background', roles.selection.candidates),
    map.entry(
      'inactiveViewSelectedLineBgColor',
      'inactive selected line background',
      roles.inactive_selection.candidates
    ),
    map.entry('cherryPickedCommitFgColor', 'cherry-picked commit text', { contrasting_text(roles.success) }),
    map.entry('cherryPickedCommitBgColor', 'cherry-picked commit background', roles.success.candidates),
    map.entry('markedBaseCommitFgColor', 'marked base commit text', { contrasting_text(roles.warning) }),
    map.entry('markedBaseCommitBgColor', 'marked base commit background', roles.warning.candidates),
    map.entry('unstagedChangesColor', 'unstaged change text', roles.error.candidates),
    map.entry('defaultFgColor', 'default text', default_fg.candidates),
  }
end

function M.generate(highlights, terminal_palette)
  local content = {
    'gui:',
    '  theme:',
  }

  for _, mapping in ipairs(M.describe(highlights, terminal_palette)) do
    if mapping.value then
      table.insert(content, string.format('    %s:', mapping.target))
      table.insert(content, string.format('      - "%s"', mapping.value))
      for _, modifier in ipairs(mapping.modifiers) do
        table.insert(content, string.format('      - %s', modifier))
      end
      table.insert(content, '')
    end
  end

  return content
end

return M
