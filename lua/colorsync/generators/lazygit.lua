local M = {}

function M.describe(highlights)
  local map = require('colorsync.mapping')
  highlights = highlights or {}

  local function hl(group, attribute)
    return map.highlight(highlights, group, attribute)
  end

  return {
    map.entry('activeBorderColor', 'active panel border', {
      hl('Title', 'fg'),
      hl('DiagnosticInfo', 'fg'),
    }),
    map.entry('inactiveBorderColor', 'inactive panel border', {
      hl('FloatBorder', 'fg'),
      hl('Comment', 'fg'),
    }),
    map.entry('searchingActiveBorderColor', 'search panel border', {
      hl('IncSearch', 'fg'),
      hl('Search', 'fg'),
    }),
    map.entry('optionsTextColor', 'option text', { hl('Normal', 'fg') }),
    map.entry('selectedLineFgColor', 'selected line text', { hl('Visual', 'fg') }),
    map.entry('selectedLineBgColor', 'selected line background', {
      hl('Visual', 'bg'),
    }),
    map.entry('cherryPickedCommitFgColor', 'cherry-picked commit text', {
      hl('Normal', 'fg'),
    }),
    map.entry('cherryPickedCommitBgColor', 'cherry-picked commit background', {
      hl('DiffAdd', 'bg'),
    }),
    map.entry('markedBaseCommitFgColor', 'marked base commit text', {
      hl('Normal', 'fg'),
    }),
    map.entry('markedBaseCommitBgColor', 'marked base commit background', {
      hl('DiffChange', 'bg'),
    }),
    map.entry('unstagedChangesColor', 'unstaged change text', {
      hl('DiagnosticError', 'fg'),
      hl('ErrorMsg', 'fg'),
    }),
    map.entry('defaultFgColor', 'default text', { hl('Normal', 'fg') }),
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
