local M = {}

-- Helper to escape XML special characters
local function xml_escape(str)
  if not str then
    return ''
  end
  str = string.gsub(str, '&', '&amp;')
  str = string.gsub(str, '<', '&lt;')
  str = string.gsub(str, '>', '&gt;')
  str = string.gsub(str, '"', '&quot;')
  str = string.gsub(str, "'", '&apos;')
  return str
end

-- Helper to add a scope rule
local function add_scope_rule(content, name, scope, fg, bg, font_style)
  table.insert(content, '      <dict>')
  table.insert(content, '        <key>name</key>')
  table.insert(content, string.format('        <string>%s</string>', xml_escape(name)))
  table.insert(content, '        <key>scope</key>')
  table.insert(content, string.format('        <string>%s</string>', xml_escape(scope)))
  table.insert(content, '        <key>settings</key>')
  table.insert(content, '        <dict>')

  if fg then
    table.insert(content, '          <key>foreground</key>')
    table.insert(content, string.format('          <string>%s</string>', fg))
  end

  if bg then
    table.insert(content, '          <key>background</key>')
    table.insert(content, string.format('          <string>%s</string>', bg))
  end

  if font_style then
    table.insert(content, '          <key>fontStyle</key>')
    table.insert(content, string.format('          <string>%s</string>', font_style))
  end

  table.insert(content, '        </dict>')
  table.insert(content, '      </dict>')
end

function M.generate(highlights, palette)
  local content = {}

  -- XML header
  table.insert(content, '<?xml version="1.0" encoding="UTF-8"?>')
  table.insert(
    content,
    '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'
  )
  table.insert(content, '<plist version="1.0">')
  table.insert(content, '  <dict>')
  table.insert(content, '    <key>name</key>')
  table.insert(content, '    <string>Neovim ColorSync</string>')
  table.insert(content, '    <key>settings</key>')
  table.insert(content, '    <array>')

  -- Global settings
  table.insert(content, '      <dict>')
  table.insert(content, '        <key>settings</key>')
  table.insert(content, '        <dict>')

  -- Background
  if highlights.Normal and highlights.Normal.bg then
    table.insert(content, '          <key>background</key>')
    table.insert(content, string.format('          <string>%s</string>', highlights.Normal.bg))
  end

  -- Foreground
  if highlights.Normal and highlights.Normal.fg then
    table.insert(content, '          <key>foreground</key>')
    table.insert(content, string.format('          <string>%s</string>', highlights.Normal.fg))
  end

  -- Caret
  if highlights.Cursor and highlights.Cursor.bg then
    table.insert(content, '          <key>caret</key>')
    table.insert(content, string.format('          <string>%s</string>', highlights.Cursor.bg))
  end

  -- Line highlight
  if highlights.CursorLine and highlights.CursorLine.bg then
    table.insert(content, '          <key>lineHighlight</key>')
    table.insert(content, string.format('          <string>%s</string>', highlights.CursorLine.bg))
  end

  -- Selection
  if highlights.Visual and highlights.Visual.bg then
    table.insert(content, '          <key>selection</key>')
    table.insert(content, string.format('          <string>%s</string>', highlights.Visual.bg))
  end

  -- Find highlight
  if highlights.Search and highlights.Search.bg then
    table.insert(content, '          <key>findHighlight</key>')
    table.insert(content, string.format('          <string>%s</string>', highlights.Search.bg))
  end

  -- Guides (indent guides)
  if highlights.IndentBlanklineChar and highlights.IndentBlanklineChar.fg then
    table.insert(content, '          <key>guide</key>')
    table.insert(content, string.format('          <string>%s</string>', highlights.IndentBlanklineChar.fg))
  elseif highlights.NonText and highlights.NonText.fg then
    table.insert(content, '          <key>guide</key>')
    table.insert(content, string.format('          <string>%s</string>', highlights.NonText.fg))
  end

  -- Active guide
  if highlights.CursorLineNr and highlights.CursorLineNr.fg then
    table.insert(content, '          <key>activeGuide</key>')
    table.insert(content, string.format('          <string>%s</string>', highlights.CursorLineNr.fg))
  end

  table.insert(content, '        </dict>')
  table.insert(content, '      </dict>')

  -- Scope styles - map TextMate scopes to Neovim highlight groups

  -- Comments
  local comment_fg = highlights['@comment'] and highlights['@comment'].fg
    or highlights.Comment and highlights.Comment.fg
  if comment_fg then
    add_scope_rule(content, 'Comment', 'comment', comment_fg, nil, 'italic')
  end

  -- Strings
  local string_fg = highlights['@string'] and highlights['@string'].fg or highlights.String and highlights.String.fg
  if string_fg then
    add_scope_rule(content, 'String', 'string', string_fg)
  end

  -- Numbers
  local number_fg = highlights['@number'] and highlights['@number'].fg or highlights.Number and highlights.Number.fg
  if number_fg then
    add_scope_rule(content, 'Number', 'constant.numeric', number_fg)
  end

  -- Constants
  local constant_fg = highlights['@constant'] and highlights['@constant'].fg
    or highlights.Constant and highlights.Constant.fg
  if constant_fg then
    add_scope_rule(content, 'Constant', 'constant', constant_fg)
  end

  -- Booleans
  local boolean_fg = highlights['@boolean'] and highlights['@boolean'].fg
    or highlights.Boolean and highlights.Boolean.fg
    or constant_fg
  if boolean_fg then
    add_scope_rule(content, 'Boolean', 'constant.language', boolean_fg)
  end

  -- Escape characters
  local escape_fg = highlights['@string.escape'] and highlights['@string.escape'].fg
    or highlights.SpecialChar and highlights.SpecialChar.fg
  if escape_fg then
    add_scope_rule(content, 'Escape', 'constant.character.escape', escape_fg)
  end

  -- Keywords
  local keyword_fg = highlights['@keyword'] and highlights['@keyword'].fg
    or highlights.Keyword and highlights.Keyword.fg
  if keyword_fg then
    add_scope_rule(content, 'Keyword', 'keyword', keyword_fg)
    add_scope_rule(content, 'Keyword Control', 'keyword.control', keyword_fg)
  end

  -- Storage (var, const, function, class keywords)
  local storage_fg = highlights['@keyword.function'] and highlights['@keyword.function'].fg or keyword_fg
  if storage_fg then
    add_scope_rule(content, 'Storage', 'storage', storage_fg)
  end

  -- Operators
  local operator_fg = highlights['@operator'] and highlights['@operator'].fg
    or highlights.Operator and highlights.Operator.fg
  if operator_fg then
    add_scope_rule(content, 'Operator', 'keyword.operator', operator_fg)
  end

  -- Functions
  local function_fg = highlights['@function'] and highlights['@function'].fg
    or highlights.Function and highlights.Function.fg
  if function_fg then
    add_scope_rule(content, 'Function', 'entity.name.function', function_fg)
    add_scope_rule(content, 'Function Call', 'support.function', function_fg)
  end

  -- Types/Classes
  local type_fg = highlights['@type'] and highlights['@type'].fg or highlights.Type and highlights.Type.fg
  if type_fg then
    add_scope_rule(content, 'Type', 'entity.name.type', type_fg)
    add_scope_rule(content, 'Class', 'entity.name.class', type_fg)
    add_scope_rule(content, 'Support Class', 'support.class', type_fg)
  end

  -- Variables
  local variable_fg = highlights['@variable'] and highlights['@variable'].fg
    or highlights.Identifier and highlights.Identifier.fg
  if variable_fg then
    add_scope_rule(content, 'Variable', 'variable', variable_fg)
  end

  -- Parameters
  local parameter_fg = highlights['@parameter'] and highlights['@parameter'].fg
    or highlights.Normal and highlights.Normal.fg
  if parameter_fg then
    add_scope_rule(content, 'Parameter', 'variable.parameter', parameter_fg)
  end

  -- Properties/Fields
  local property_fg = highlights['@property'] and highlights['@property'].fg
    or highlights['@field'] and highlights['@field'].fg
    or variable_fg
  if property_fg then
    add_scope_rule(content, 'Property', 'variable.other.property', property_fg)
  end

  -- Tags (HTML/XML)
  local tag_fg = highlights['@tag'] and highlights['@tag'].fg or highlights.Tag and highlights.Tag.fg or variable_fg
  if tag_fg then
    add_scope_rule(content, 'Tag', 'entity.name.tag', tag_fg)
  end

  -- Attributes
  local attribute_fg = highlights['@attribute'] and highlights['@attribute'].fg or type_fg
  if attribute_fg then
    add_scope_rule(content, 'Attribute', 'entity.other.attribute-name', attribute_fg)
  end

  -- Punctuation
  local punctuation_fg = highlights['@punctuation.delimiter'] and highlights['@punctuation.delimiter'].fg
    or highlights.Normal and highlights.Normal.fg
  if punctuation_fg then
    add_scope_rule(content, 'Punctuation', 'punctuation', punctuation_fg)
  end

  -- Special
  local special_fg = highlights['@constant.builtin'] and highlights['@constant.builtin'].fg
    or highlights.Special and highlights.Special.fg
  if special_fg then
    add_scope_rule(content, 'Special', 'support.type', special_fg)
  end

  -- Errors
  local error_fg = highlights.Error and highlights.Error.fg or highlights.ErrorMsg and highlights.ErrorMsg.fg
  local error_bg = highlights.Error and highlights.Error.bg
  if error_fg then
    add_scope_rule(content, 'Invalid', 'invalid.illegal', error_fg, error_bg)
  end

  -- Warnings
  local warning_fg = highlights.WarningMsg and highlights.WarningMsg.fg
    or highlights.DiagnosticWarn and highlights.DiagnosticWarn.fg
  if warning_fg then
    add_scope_rule(content, 'Deprecated', 'invalid.deprecated', warning_fg)
  end

  -- Markup - Headings
  local heading_fg = highlights['@markup.heading'] and highlights['@markup.heading'].fg or variable_fg
  if heading_fg then
    add_scope_rule(content, 'Markup Heading', 'markup.heading', heading_fg, nil, 'bold')
  end

  -- Markup - Bold
  local bold_fg = highlights['@markup.strong'] and highlights['@markup.strong'].fg
    or highlights.Normal and highlights.Normal.fg
  if bold_fg then
    add_scope_rule(content, 'Markup Bold', 'markup.bold', bold_fg, nil, 'bold')
  end

  -- Markup - Italic
  local italic_fg = highlights['@markup.italic'] and highlights['@markup.italic'].fg
    or highlights.Normal and highlights.Normal.fg
  if italic_fg then
    add_scope_rule(content, 'Markup Italic', 'markup.italic', italic_fg, nil, 'italic')
  end

  -- Markup - Links
  local link_fg = highlights['@markup.link'] and highlights['@markup.link'].fg or function_fg
  if link_fg then
    add_scope_rule(content, 'Markup Link', 'markup.underline.link', link_fg)
  end

  -- Markup - Quote
  local quote_fg = highlights.Comment and highlights.Comment.fg
  if quote_fg then
    add_scope_rule(content, 'Markup Quote', 'markup.quote', quote_fg, nil, 'italic')
  end

  -- Markup - Raw/Code
  if string_fg then
    add_scope_rule(content, 'Markup Raw', 'markup.raw', string_fg)
  end

  -- Diff - Added
  local diff_add_fg = highlights.DiffAdd and highlights.DiffAdd.fg or highlights.Added and highlights.Added.fg
  local diff_add_bg = highlights.DiffAdd and highlights.DiffAdd.bg
  if diff_add_fg or diff_add_bg then
    add_scope_rule(content, 'Markup Inserted', 'markup.inserted', diff_add_fg, diff_add_bg)
  end

  -- Diff - Deleted
  local diff_delete_fg = highlights.DiffDelete and highlights.DiffDelete.fg
    or highlights.Removed and highlights.Removed.fg
  local diff_delete_bg = highlights.DiffDelete and highlights.DiffDelete.bg
  if diff_delete_fg or diff_delete_bg then
    add_scope_rule(content, 'Markup Deleted', 'markup.deleted', diff_delete_fg, diff_delete_bg)
  end

  -- Diff - Changed
  local diff_change_fg = highlights.DiffChange and highlights.DiffChange.fg
    or highlights.Changed and highlights.Changed.fg
  local diff_change_bg = highlights.DiffChange and highlights.DiffChange.bg
  if diff_change_fg or diff_change_bg then
    add_scope_rule(content, 'Markup Changed', 'markup.changed', diff_change_fg, diff_change_bg)
  end

  -- Close arrays and dicts
  table.insert(content, '    </array>')
  table.insert(content, '  </dict>')
  table.insert(content, '</plist>')

  return content
end

return M
