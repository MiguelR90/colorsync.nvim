local M = {}

function M.generate(highlights, palette)
  local content = {}

  -- Start YAML structure
  table.insert(content, 'gui:')
  table.insert(content, '  theme:')

  -- Helper function to format color entry
  local function add_entry(name, color, bold)
    if color then
      table.insert(content, string.format('    %s:', name))
      table.insert(content, string.format('      - "%s"', color))
      if bold then
        table.insert(content, '      - bold')
      end
      table.insert(content, '') -- split with new lines
    end
  end

  -- Border colors (using treesitter highlight groups for better contrast)
  -- activeBorderColor: focused window (use vibrant treesitter colors)
  local active_border = highlights['@function'] and highlights['@function'].fg
    or highlights['@keyword'] and highlights['@keyword'].fg
    or highlights.Function and highlights.Function.fg
    or palette[4]
    or palette[12] -- blue fallback
  add_entry('activeBorderColor', active_border, true)

  -- inactiveBorderColor: non-focused windows (use subtle treesitter colors)
  local inactive_border = highlights['@comment'] and highlights['@comment'].fg
    or highlights.Comment and highlights.Comment.fg
    or highlights.NonText and highlights.NonText.fg
    or palette[8] -- gray fallback
  add_entry('inactiveBorderColor', inactive_border, false)

  -- searchingActiveBorderColor: search mode (use vibrant treesitter colors)
  local search_border = highlights['@string'] and highlights['@string'].fg
    or highlights.String and highlights.String.fg
    or highlights.IncSearch and highlights.IncSearch.bg
    or palette[6]
    or palette[14] -- cyan fallback
  add_entry('searchingActiveBorderColor', search_border, true)

  -- optionsTextColor: keybindings help (use treesitter type/keyword colors)
  local options_text = highlights['@type'] and highlights['@type'].fg
    or highlights.Type and highlights.Type.fg
    or highlights.Function and highlights.Function.fg
    or palette[4]
    or palette[12] -- blue fallback
  add_entry('optionsTextColor', options_text, false)

  -- selectedLineBgColor: selected line background (use Visual or CursorLine)
  local selected_bg = highlights.Visual and highlights.Visual.bg
    or highlights.CursorLine and highlights.CursorLine.bg
    or palette[8] -- gray fallback
  add_entry('selectedLineBgColor', selected_bg, false)

  -- inactiveViewSelectedLineBgColor: selected line when unfocused (use CursorLine or dimmer)
  local inactive_selected_bg = highlights.CursorLine and highlights.CursorLine.bg or palette[8] -- gray fallback
  add_entry('inactiveViewSelectedLineBgColor', inactive_selected_bg, false)

  -- cherryPickedCommitFgColor: copied commit foreground (use Identifier or Statement)
  local cherry_fg = highlights.Identifier and highlights.Identifier.fg or palette[4] or palette[12] -- blue fallback
  add_entry('cherryPickedCommitFgColor', cherry_fg, false)

  -- cherryPickedCommitBgColor: copied commit background (use DiffAdd or cyan)
  local cherry_bg = highlights.DiffAdd and highlights.DiffAdd.bg or palette[6] or palette[14] -- cyan fallback
  add_entry('cherryPickedCommitBgColor', cherry_bg, false)

  -- markedBaseCommitFgColor: rebase marker foreground (use Type or Keyword)
  local marked_fg = highlights.Type and highlights.Type.fg or palette[4] or palette[12] -- blue fallback
  add_entry('markedBaseCommitFgColor', marked_fg, false)

  -- markedBaseCommitBgColor: rebase marker background (use WarningMsg or yellow)
  local marked_bg = highlights.WarningMsg and highlights.WarningMsg.fg
    or highlights.DiffChange and highlights.DiffChange.bg
    or palette[3]
    or palette[11] -- yellow fallback
  add_entry('markedBaseCommitBgColor', marked_bg, false)

  -- unstagedChangesColor: unstaged changes (use DiffDelete or ErrorMsg)
  local unstaged = highlights.DiffDelete and highlights.DiffDelete.fg
    or highlights.ErrorMsg and highlights.ErrorMsg.fg
    or palette[1]
    or palette[9] -- red fallback
  add_entry('unstagedChangesColor', unstaged, false)

  -- defaultFgColor: default text (use Normal foreground)
  local default_fg = highlights.Normal and highlights.Normal.fg
  add_entry('defaultFgColor', default_fg, false)

  return content
end

return M
