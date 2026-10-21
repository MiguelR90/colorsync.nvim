local M = {}

local STYLE_ATTRIBUTES = {
  'bold',
  'italic',
  'underline',
  'undercurl',
  'underdouble',
  'underdotted',
  'underdashed',
  'strikethrough',
  'reverse',
  'standout',
  'nocombine',
}

local SYNTAX_GROUPS = {
  Boolean = true,
  Character = true,
  Comment = true,
  Conditional = true,
  Constant = true,
  Debug = true,
  Define = true,
  Delimiter = true,
  Error = true,
  Exception = true,
  Float = true,
  Function = true,
  Identifier = true,
  Include = true,
  Keyword = true,
  Label = true,
  Macro = true,
  Number = true,
  Operator = true,
  PreCondit = true,
  PreProc = true,
  Repeat = true,
  Special = true,
  SpecialChar = true,
  SpecialComment = true,
  Statement = true,
  StorageClass = true,
  String = true,
  Structure = true,
  Tag = true,
  Todo = true,
  Type = true,
  Typedef = true,
}

local UI_GROUPS = {
  ColorColumn = true,
  Conceal = true,
  Cursor = true,
  CursorColumn = true,
  CursorLine = true,
  CursorLineNr = true,
  EndOfBuffer = true,
  FloatBorder = true,
  FoldColumn = true,
  Folded = true,
  LineNr = true,
  MatchParen = true,
  ModeMsg = true,
  MoreMsg = true,
  NonText = true,
  Normal = true,
  NormalFloat = true,
  Pmenu = true,
  PmenuSel = true,
  Question = true,
  Search = true,
  SignColumn = true,
  StatusLine = true,
  StatusLineNC = true,
  TabLine = true,
  TabLineFill = true,
  TabLineSel = true,
  Title = true,
  VertSplit = true,
  Visual = true,
  WarningMsg = true,
  Whitespace = true,
  WildMenu = true,
  WinBar = true,
  WinBarNC = true,
  WinSeparator = true,
}

local function escape(value)
  return tostring(value or '')
    :gsub('&', '&amp;')
    :gsub('<', '&lt;')
    :gsub('>', '&gt;')
    :gsub('"', '&quot;')
    :gsub("'", '&#39;')
end

local function color_style(color, property)
  if type(color) == 'string' and color:match('^#%x%x%x%x%x%x$') then
    return string.format('%s:%s', property, color)
  end
  return ''
end

local function category(name)
  if name:sub(1, 1) == '@' then
    return 'Tree-sitter'
  elseif name:match('^Diagnostic') then
    return 'Diagnostics'
  elseif name:match('^Diff') then
    return 'Diff'
  elseif SYNTAX_GROUPS[name] then
    return 'Syntax'
  elseif UI_GROUPS[name] then
    return 'UI'
  end
  return 'Plugin / other'
end

local function modifiers(attributes)
  local values = {}
  for _, attribute in ipairs(STYLE_ATTRIBUTES) do
    if attributes[attribute] then
      table.insert(values, attribute)
    end
  end
  if attributes.blend ~= nil then
    table.insert(values, 'blend=' .. attributes.blend)
  end
  return values
end

local function swatch(color, class_name)
  local label = color or 'unset'
  return string.format(
    '<span class="swatch %s" style="%s" title="%s"></span><code>%s</code>',
    class_name or '',
    color_style(color, 'background'),
    escape(label),
    escape(label)
  )
end

local function highlight_preview(attributes)
  local styles = {
    color_style(attributes.fg, 'color'),
    color_style(attributes.bg, 'background'),
    color_style(attributes.sp, 'text-decoration-color'),
  }
  if attributes.bold then
    table.insert(styles, 'font-weight:700')
  end
  if attributes.italic then
    table.insert(styles, 'font-style:italic')
  end
  if attributes.underline or attributes.undercurl or attributes.underdouble or attributes.underdotted then
    table.insert(styles, 'text-decoration-line:underline')
  end
  if attributes.strikethrough then
    table.insert(styles, 'text-decoration-line:line-through')
  end
  return string.format('<span class="preview" style="%s">Sample text</span>', table.concat(styles, ';'))
end

local function render_palette(data)
  local rows = {}
  for index = 0, 15 do
    local source = data.terminal_sources[index]
    table.insert(
      rows,
      string.format(
        '<article class="palette-card"><div class="palette-index">%d</div>%s'
          .. '<div><strong>%s</strong><small class="source %s">%s</small></div></article>',
        index,
        swatch(data.terminal_palette[index], 'large'),
        escape(source.description),
        escape(source.kind),
        escape(source.label)
      )
    )
  end
  return table.concat(rows, '\n')
end

local function render_highlights(data)
  local rows = {}
  for _, name in ipairs(data.highlight_names) do
    local resolved = data.highlights[name] or {}
    local definition = data.highlight_definitions[name] or {}
    local group_category = category(name)
    local style_names = modifiers(resolved)
    local link = definition.link and ('→ ' .. definition.link) or 'direct definition'
    local searchable = table
      .concat({
        name,
        group_category,
        link,
        resolved.fg or '',
        resolved.bg or '',
        resolved.sp or '',
        table.concat(style_names, ' '),
      }, ' ')
      :lower()

    table.insert(
      rows,
      string.format(
        '<tr class="highlight-row" data-category="%s" data-search="%s">'
          .. '<td><code>%s</code><small>%s</small></td>'
          .. '<td><span class="category">%s</span></td>'
          .. '<td>%s</td><td>%s</td><td>%s</td>'
          .. '<td>%s</td><td>%s</td></tr>',
        escape(group_category),
        escape(searchable),
        escape(name),
        escape(link),
        escape(group_category),
        swatch(resolved.fg),
        swatch(resolved.bg),
        swatch(resolved.sp),
        escape(table.concat(style_names, ', ')),
        highlight_preview(resolved)
      )
    )
  end
  return table.concat(rows, '\n')
end

local function candidate_label(candidate, data)
  if candidate.kind == 'terminal' then
    local index = candidate.label:match('terminal_color_(%d+)')
    local source = index and data.terminal_sources[tonumber(index)]
    if source and source.kind ~= 'terminal' then
      return string.format('%s ← %s', candidate.label, source.label)
    end
  end
  return candidate.label
end

local function render_candidate(candidate, selected, data)
  local class_name = candidate == selected and 'candidate selected' or 'candidate'
  return string.format(
    '<li class="%s">%s <span>%s</span></li>',
    class_name,
    swatch(candidate.value),
    escape(candidate_label(candidate, data))
  )
end

local function render_integrations(data, generators)
  local sections = {}
  local names = {}
  for name in pairs(generators) do
    table.insert(names, name)
  end
  table.sort(names)

  for _, name in ipairs(names) do
    local generator = generators[name]
    local rows = {}
    for _, mapping in ipairs(generator.describe(data.highlights, data.terminal_palette)) do
      local candidates = {}
      for _, candidate in ipairs(mapping.candidates) do
        table.insert(candidates, render_candidate(candidate, mapping.selected, data))
      end
      local modifier_text = #mapping.modifiers > 0 and (' · ' .. table.concat(mapping.modifiers, ', ')) or ''
      table.insert(
        rows,
        string.format(
          '<article class="mapping"><div class="target"><code>%s</code><small>%s%s</small></div>'
            .. '<div class="connector" aria-hidden="true">→</div>'
            .. '<div class="chosen">%s<strong>%s</strong></div>'
            .. '<details><summary>%d fallback candidates</summary><ol>%s</ol></details></article>',
          escape(mapping.target),
          escape(mapping.role),
          escape(modifier_text),
          swatch(mapping.value, 'large'),
          escape(mapping.selected and candidate_label(mapping.selected, data) or 'unset'),
          #mapping.candidates,
          table.concat(candidates, '')
        )
      )
    end

    table.insert(
      sections,
      string.format(
        '<section class="integration"><h3>%s <span>%d targets</span></h3>%s</section>',
        escape(name),
        #rows,
        table.concat(rows, '\n')
      )
    )
  end
  return table.concat(sections, '\n')
end

function M.generate(data, generators)
  local linked_count = 0
  for _, definition in pairs(data.highlight_definitions) do
    if definition.link then
      linked_count = linked_count + 1
    end
  end

  local template = [==[<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>ColorSync report · {{SCHEME}}</title>
<style>
:root{color-scheme:dark;--bg:#111418;--panel:#191e24;--panel2:#222933;--text:#e6edf3;--muted:#9da7b3;--line:#35404d;--accent:#73b7ff}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);font:15px/1.45 system-ui,sans-serif}
main{width:min(1500px,94vw);margin:auto;padding:3rem 0 6rem}h1{font-size:2.5rem;margin:0}h2{margin-top:3.5rem;font-size:1.7rem}
h3{font-size:1.25rem}h3 span,.lede,small{color:var(--muted);font-weight:400}code{font-family:ui-monospace,SFMono-Regular,monospace}
.summary{display:flex;gap:1rem;flex-wrap:wrap;margin:1.5rem 0}.stat,.flow div{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:1rem}
.stat strong{display:block;font-size:1.6rem}.flow{display:grid;grid-template-columns:1fr auto 2fr auto 1fr;align-items:center;gap:.7rem}
.flow div{text-align:center}.flow b{display:block}.flow .exposed span{display:inline-block;margin:.4rem;padding:.6rem;background:var(--panel2);border-radius:6px}.arrow{color:var(--accent);font-size:1.5rem}.note{border-left:3px solid var(--accent);padding:.7rem 1rem;background:var(--panel)}
.palette{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:.7rem}.palette-card{display:grid;grid-template-columns:2rem 2.5rem 1fr;gap:.7rem;align-items:center;background:var(--panel);padding:.75rem;border-radius:8px}
.palette-index{font-size:1.3rem;color:var(--muted)}.palette-card small,.highlight-row small,.target small{display:block}.source.terminal{color:#7ee787}.source.unset{color:var(--muted)}
.swatch{display:inline-block;width:1rem;height:1rem;margin-right:.4rem;border:1px solid #718096;border-radius:3px;vertical-align:-.15rem;background-image:linear-gradient(45deg,#555 25%,transparent 25%),linear-gradient(-45deg,#555 25%,transparent 25%),linear-gradient(45deg,transparent 75%,#555 75%),linear-gradient(-45deg,transparent 75%,#555 75%);background-size:8px 8px;background-position:0 0,0 4px,4px -4px,-4px 0}
.swatch.large{width:2.2rem;height:2.2rem}.controls{position:sticky;top:0;z-index:2;display:flex;gap:.7rem;padding:.8rem;background:rgba(17,20,24,.95);border-bottom:1px solid var(--line)}
input,select{background:var(--panel2);color:var(--text);border:1px solid var(--line);border-radius:6px;padding:.65rem}input{flex:1}table{border-collapse:collapse;width:100%;font-size:.88rem}
th{position:sticky;top:61px;background:var(--panel2);text-align:left}th,td{padding:.6rem;border-bottom:1px solid var(--line);vertical-align:top}.category{white-space:nowrap;color:var(--muted)}
.preview{display:inline-block;min-width:8rem;padding:.3rem .5rem;border:1px solid var(--line);border-radius:4px}.integration{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:1rem;margin:1rem 0}
.mapping{display:grid;grid-template-columns:minmax(180px,1fr) 2rem minmax(220px,1fr) minmax(220px,1.3fr);gap:1rem;align-items:center;padding:.75rem;border-top:1px solid var(--line)}
.connector{font-size:1.5rem;color:var(--accent)}.chosen{display:flex;align-items:center;gap:.5rem}.candidate{color:var(--muted)}.candidate.selected{color:var(--text);font-weight:700}details ol{padding-left:1.5rem;margin:.5rem 0}
@media(max-width:850px){.flow{grid-template-columns:1fr}.arrow{transform:rotate(90deg);text-align:center}.mapping{grid-template-columns:1fr}.connector{transform:rotate(90deg)}.highlights{overflow:auto}th{position:static}}
</style>
</head>
<body><main>
<header><h1>{{SCHEME}}</h1><p class="lede">A live map of how this Neovim colorscheme becomes external tool themes.</p>
<div class="summary"><div class="stat"><strong>{{GROUP_COUNT}}</strong>highlight groups</div><div class="stat"><strong>{{LINK_COUNT}}</strong>linked groups</div><div class="stat"><strong>16</strong>ANSI slots</div></div></header>
<section><h2>The four color layers</h2><div class="flow"><div><b>Private palette</b>Theme author’s internal names</div><span class="arrow">→</span><div class="exposed"><b>Neovim’s public surfaces</b><span>Highlight groups</span><span>ANSI terminal globals</span></div><span class="arrow">→</span><div><b>ColorSync targets</b>External tool settings</div></div>
<p class="note">A colorscheme uses its private palette to define highlights and ANSI globals in parallel. Neither Neovim nor ColorSync derives one from the other. A missing terminal global stays unset. Highlight categories below are report heuristics, not an official hierarchy.</p></section>
<section><h2>ANSI terminal palette</h2><p>Green sources are <code>terminal_color_N</code> globals set by the colorscheme. Muted sources are slots the colorscheme left unset.</p><div class="palette">{{PALETTE}}</div></section>
<section><h2>Highlight explorer</h2><p>“Direct definition” is the group’s own style. An arrow identifies a link; displayed colors and modifiers are the fully resolved result.</p>
<div class="controls"><input id="search" type="search" placeholder="Search groups, links, colors, or modifiers"><select id="category"><option value="">All categories</option><option>UI</option><option>Syntax</option><option>Tree-sitter</option><option>Diagnostics</option><option>Diff</option><option>Plugin / other</option></select><span id="visible"></span></div>
<div class="highlights"><table><thead><tr><th>Group / link</th><th>Category</th><th>Foreground</th><th>Background</th><th>Special</th><th>Modifiers</th><th>Resolved preview</th></tr></thead><tbody>{{HIGHLIGHTS}}</tbody></table></div></section>
<section><h2>Integration mapping</h2><p>Each target points to its chosen Neovim source. Expand a row to see the ordered fallback chain; the bold entry won.</p>{{INTEGRATIONS}}</section>
</main>
<script>
const search=document.querySelector('#search'),category=document.querySelector('#category'),rows=[...document.querySelectorAll('.highlight-row')],visible=document.querySelector('#visible');
function filter(){const q=search.value.trim().toLowerCase(),c=category.value;let count=0;for(const row of rows){const show=(!q||row.dataset.search.includes(q))&&(!c||row.dataset.category===c);row.hidden=!show;if(show)count++}visible.textContent=count+' shown'}
search.addEventListener('input',filter);category.addEventListener('change',filter);filter();
</script></body></html>]==]

  local replacements = {
    SCHEME = escape(data.colorscheme),
    GROUP_COUNT = tostring(#data.highlight_names),
    LINK_COUNT = tostring(linked_count),
    PALETTE = render_palette(data),
    HIGHLIGHTS = render_highlights(data),
    INTEGRATIONS = render_integrations(data, generators),
  }
  for key, value in pairs(replacements) do
    template = template:gsub('{{' .. key .. '}}', function()
      return value
    end)
  end
  return template
end

return M
