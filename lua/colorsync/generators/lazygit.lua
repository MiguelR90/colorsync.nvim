local M = {}

function M.generate(highlights, palette)
  local content = {}

  -- Helper function to format color entry
  local function add_color(name, color, add_bold)
    if color then
      table.insert(content, string.format('    %s:', name))
      table.insert(content, string.format('      - "%s"', color))
      if add_bold then
        table.insert(content, '      - bold')
      end
    end
  end

  -- Start YAML structure
  table.insert(content, 'gui:')
  table.insert(content, '  theme:')

  -- Border colors (using standard Neovim highlight groups that TUIs link to)
  -- activeBorderColor: focused window (FloatBorder links to NormalFloat)
  local active_border = highlights.NormalFloat and highlights.NormalFloat.fg
    or highlights.FloatBorder and highlights.FloatBorder.fg
    or highlights.PmenuSel and highlights.PmenuSel.bg
    or palette[4]
    or palette[12] -- blue fallback
  add_color('activeBorderColor', active_border, true)
  table.insert(content, '')

  -- inactiveBorderColor: non-focused windows (WinSeparator links to Normal)
  local inactive_border = highlights.WinSeparator and highlights.WinSeparator.fg
    or highlights.NonText and highlights.NonText.fg
    or highlights.Comment and highlights.Comment.fg
    or palette[8] -- gray fallback
  add_color('inactiveBorderColor', inactive_border, false)
  table.insert(content, '')

  -- searchingActiveBorderColor: search mode (use IncSearch which is standard)
  local search_border = highlights.IncSearch and highlights.IncSearch.bg
    or highlights.Search and highlights.Search.bg
    or palette[6]
    or palette[14] -- cyan fallback
  add_color('searchingActiveBorderColor', search_border, true)
  table.insert(content, '')

  -- optionsTextColor: keybindings help (use Function or Special)
  local options_text = highlights.Function and highlights.Function.fg
    or highlights.Special and highlights.Special.fg
    or palette[4]
    or palette[12] -- blue fallback
  add_color('optionsTextColor', options_text, false)
  table.insert(content, '')

  -- selectedLineBgColor: selected line background (use Visual or CursorLine)
  local selected_bg = highlights.Visual and highlights.Visual.bg
    or highlights.CursorLine and highlights.CursorLine.bg
    or palette[8] -- gray fallback
  add_color('selectedLineBgColor', selected_bg, false)
  table.insert(content, '')

  -- inactiveViewSelectedLineBgColor: selected line when unfocused (use CursorLine or dimmer)
  local inactive_selected_bg = highlights.CursorLine and highlights.CursorLine.bg or palette[8] -- gray fallback
  add_color('inactiveViewSelectedLineBgColor', inactive_selected_bg, false)
  table.insert(content, '')

  -- cherryPickedCommitFgColor: copied commit foreground (use Identifier or Statement)
  local cherry_fg = highlights.Identifier and highlights.Identifier.fg or palette[4] or palette[12] -- blue fallback
  add_color('cherryPickedCommitFgColor', cherry_fg, false)
  table.insert(content, '')

  -- cherryPickedCommitBgColor: copied commit background (use DiffAdd or cyan)
  local cherry_bg = highlights.DiffAdd and highlights.DiffAdd.bg or palette[6] or palette[14] -- cyan fallback
  add_color('cherryPickedCommitBgColor', cherry_bg, false)
  table.insert(content, '')

  -- markedBaseCommitFgColor: rebase marker foreground (use Type or Keyword)
  local marked_fg = highlights.Type and highlights.Type.fg or palette[4] or palette[12] -- blue fallback
  add_color('markedBaseCommitFgColor', marked_fg, false)
  table.insert(content, '')

  -- markedBaseCommitBgColor: rebase marker background (use WarningMsg or yellow)
  local marked_bg = highlights.WarningMsg and highlights.WarningMsg.fg
    or highlights.DiffChange and highlights.DiffChange.bg
    or palette[3]
    or palette[11] -- yellow fallback
  add_color('markedBaseCommitBgColor', marked_bg, false)
  table.insert(content, '')

  -- unstagedChangesColor: unstaged changes (use DiffDelete or ErrorMsg)
  local unstaged = highlights.DiffDelete and highlights.DiffDelete.fg
    or highlights.ErrorMsg and highlights.ErrorMsg.fg
    or palette[1]
    or palette[9] -- red fallback
  add_color('unstagedChangesColor', unstaged, false)
  table.insert(content, '')

  -- defaultFgColor: default text (use Normal foreground)
  local default_fg = highlights.Normal and highlights.Normal.fg
  add_color('defaultFgColor', default_fg, false)

  -- NOTE: keep empty line at end
  table.insert(content, '')

  return content
end

return M
