local M = {}

function M.describe(highlights, terminal_palette)
  local map = require('colorsync.mapping')
  highlights = highlights or {}
  terminal_palette = terminal_palette or {}

  local function hl(group, attribute)
    return map.highlight(highlights, group, attribute)
  end

  local function ansi(index)
    return map.terminal(terminal_palette, index)
  end

  local function entry(target, role, candidates)
    return map.entry(target, role, candidates)
  end

  return {
    entry('fg', 'default text', { hl('Normal', 'fg'), map.literal('#ffffff', 'hardcoded fallback') }),
    entry('bg', 'default background', { hl('Normal', 'bg'), map.literal('#000000', 'hardcoded fallback') }),
    entry('hl', 'matched text', { ansi(4), ansi(12), map.literal('#4fa6ed', 'hardcoded fallback') }),
    entry('fg+', 'selected text', { hl('Normal', 'fg'), map.literal('#ffffff', 'hardcoded fallback') }),
    entry('bg+', 'selected background', {
      ansi(8),
      hl('Normal', 'bg'),
      map.literal('#000000', 'hardcoded fallback'),
    }),
    entry('hl+', 'selected matched text', { ansi(12), ansi(4), map.literal('#4fa6ed', 'hardcoded fallback') }),
    entry('info', 'informational text', { ansi(6), ansi(14), map.literal('#00ffff', 'hardcoded fallback') }),
    entry('border', 'border', { ansi(8), map.literal('#808080', 'hardcoded fallback') }),
    entry('prompt', 'prompt', { ansi(2), ansi(10), map.literal('#00ff00', 'hardcoded fallback') }),
    entry('pointer', 'selection pointer', { ansi(5), ansi(13), map.literal('#ff00ff', 'hardcoded fallback') }),
    entry('marker', 'multi-select marker', { ansi(3), ansi(11), map.literal('#ffff00', 'hardcoded fallback') }),
    entry('spinner', 'loading spinner', { ansi(6), ansi(14), map.literal('#00ffff', 'hardcoded fallback') }),
    entry('header', 'header', { ansi(4), ansi(12), map.literal('#4fa6ed', 'hardcoded fallback') }),
    entry('gutter', 'list gutter', { hl('Normal', 'bg'), map.literal('#000000', 'hardcoded fallback') }),
  }
end

function M.generate(highlights, terminal_palette)
  local mappings = M.describe(highlights, terminal_palette)

  -- Generate fzf config file format (plain text, no shell exports)
  local content = {}
  for _, mapping in ipairs(mappings) do
    table.insert(content, string.format('--color=%s:%s', mapping.target, mapping.value))
  end

  -- NOTE: keep otherwise command line is incorrectly configured
  table.insert(content, '')

  return content
end

return M
