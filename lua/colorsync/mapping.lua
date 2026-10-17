local M = {}

function M.highlight(highlights, group, attribute)
  return {
    kind = 'highlight',
    label = string.format('%s.%s', group, attribute),
    value = highlights[group] and highlights[group][attribute],
  }
end

function M.terminal(terminal_palette, index)
  return {
    kind = 'terminal',
    label = string.format('terminal_color_%d', index),
    value = terminal_palette[index],
  }
end

function M.literal(value, label)
  return {
    kind = 'literal',
    label = label or tostring(value),
    value = value,
  }
end

function M.derived(value, label)
  return {
    kind = 'derived',
    label = label,
    value = value,
  }
end

function M.entry(target, role, candidates, modifiers)
  local selected
  for _, candidate in ipairs(candidates) do
    if candidate.value ~= nil then
      selected = candidate
      break
    end
  end

  return {
    target = target,
    role = role,
    candidates = candidates,
    selected = selected,
    value = selected and selected.value,
    modifiers = modifiers or {},
  }
end

return M
