# ColorSync Highlight Groups Reference

This document provides a reference for Neovim highlight groups that can be used when creating colorscheme generators.

## Mental Model

A Neovim colorscheme has several related but distinct layers:

1. **Private palette:** Names such as `bg0`, `red`, or `aqua` inside a colorscheme's implementation. Neovim does not define an API for this layer, so ColorSync cannot read it generically.
2. **Highlight groups:** Semantic styles such as `Normal`, `Visual`, `DiagnosticError`, and `@function`. A group can define colors and modifiers directly or link to another group.
3. **ANSI terminal palette:** The separate globals `vim.g.terminal_color_0` through `vim.g.terminal_color_15`, used by terminal applications running inside Neovim.
4. **Integration targets:** Tool-specific fields selected from resolved highlights or ANSI slots through ordered fallback chains.

ColorSync records both the direct highlight definition and the resolved result. Generators use the resolved result; the visual report preserves links so the relationship remains inspectable.

## Basic Highlight Groups

| Group | Purpose | Typical Color |
|-------|---------|---------------|
| Normal | Default text and background | fg: white, bg: black |
| NormalFloat | Floating window text | fg: white, bg: dark gray |
| FloatBorder | Floating window borders | fg: gray |
| Comment | Code comments | fg: gray/dim |
| Constant | Literal constants | fg: orange/red |
| String | String literals | fg: green/yellow |
| Number | Numeric literals | fg: orange |
| Boolean | Boolean values | fg: orange |
| Identifier | Variable names | fg: white/cyan |
| Function | Function names | fg: blue/purple |
| Statement | Language statements | fg: magenta/pink |
| Keyword | Language keywords | fg: magenta/purple |
| Conditional | Conditional keywords (if/else) | fg: magenta |
| Repeat | Loop keywords (for/while) | fg: magenta |
| Type | Type names | fg: cyan/blue |
| Special | Special characters | fg: cyan |
| Operator | Operators (+, =, etc.) | fg: white/cyan |
| PreProc | Preprocessor directives | fg: cyan |
| Error | Error messages | fg: red |
| ErrorMsg | Error messages in command line | fg: red |
| WarningMsg | Warning messages | fg: yellow |
| Visual | Visual selection | bg: blue/gray |
| CursorLine | Current line highlight | bg: gray |
| Search | Search matches | bg: yellow |
| IncSearch | Incremental search | bg: orange/cyan |
| Pmenu | Popup menu | bg: gray |
| PmenuSel | Popup menu selected item | bg: blue |
| StatusLine | Status line (active) | fg: white, bg: gray |
| StatusLineNC | Status line (inactive) | fg: gray, bg: darker gray |
| WinSeparator | Window separators | fg: gray |
| VertSplit | Vertical splits (legacy) | fg: gray |
| LineNr | Line numbers | fg: gray |
| NonText | Non-text characters | fg: dark gray |
| Cursor | Cursor character | fg/bg: inverted |

## Tree-sitter Highlight Groups

| Tree-sitter group | Typical purpose | Commonly linked to | Example code |
|-------------------|-----------------|-------------------|--------------|
| @variable | Generic variables and identifiers | Identifier | `x`, `my_var`, `result` |
| @variable.builtin | Built-in variables provided by language/runtime | Special | `self`, `this`, `_` |
| @constant | Literal constants | Constant | `PI`, `MAX_LEN` |
| @constant.builtin | Built-in constants | Special | `true`, `false`, `nil`, `None` |
| @string | String literals | String | `"Hello"`, `'world'` |
| @string.escape | Escapes within strings | SpecialChar | `\n`, `\t` |
| @number | Numeric literals | Number | `42`, `3.14` |
| @boolean | Boolean literals | Boolean | `true`, `false` |
| @type | Type identifiers | Type | `int`, `User`, `MyClass` |
| @type.builtin | Built-in types | Type | `string`, `float`, `table` |
| @function | Function and method names | Function | `print()`, `get_value()` |
| @function.call | Function call usage | Function | `map()`, `len()` |
| @function.builtin | Built-in or standard library functions | Function | `print()`, `len()` |
| @parameter | Function or method parameters | Identifier | `function foo(x, y)` |
| @field | Object or struct field names | Identifier | `obj.name` |
| @property | Properties in classes or objects | Identifier | `this.value` |
| @keyword | Language keywords | Keyword | `if`, `for`, `return` |
| @keyword.function | Keywords used in function declarations | Keyword | `function`, `def`, `fn` |
| @keyword.return | Return statements | Keyword | `return` |
| @conditional | Conditional statements | Conditional | `if`, `else`, `switch` |
| @repeat | Looping constructs | Repeat | `for`, `while` |
| @operator | Symbols that perform operations | Operator | `+`, `=`, `==` |
| @punctuation.bracket | Brackets and parentheses | Delimiter | `()`, `{}`, `[]` |
| @punctuation.delimiter | Commas, semicolons, etc. | Delimiter | `,`, `;` |
| @comment | Code comments | Comment | `-- note`, `// comment` |

## Structural / Non-code Groups

| Group | Description | Typical use |
|-------|-------------|-------------|
| @module | Module or namespace name | Import or require statements |
| @namespace | Namespace identifiers | `my.module`, `std::string` |
| @tag | XML/HTML tags | `div`, `span`, etc. |
| @attribute | HTML attributes or annotations | `class="foo"`, `@decorator` |
| @label | Goto labels or switch labels | `case`, `label:` |

## Diagnostic / Meta Groups

| Group | Description | Example |
|-------|-------------|---------|
| @error | Parser or syntax errors | Incorrect syntax regions |
| @todo | TODO or FIXME comments | `-- TODO: refactor` |
| @note, @warning, @danger | For injected doc comments | Highlight semantic warnings |

## Diff Groups

| Group | Purpose | Typical Color |
|-------|---------|---------------|
| DiffAdd | Added lines in diff | bg: dark green |
| DiffChange | Changed lines in diff | bg: dark blue |
| DiffDelete | Deleted lines in diff | fg: red |
| DiffText | Changed text within a line | bg: lighter blue |

## Diagnostic Groups

| Group | Purpose | Typical Color |
|-------|---------|---------------|
| DiagnosticError | Error diagnostic text | fg: red |
| DiagnosticWarn | Warning diagnostic text | fg: yellow |
| DiagnosticInfo | Info diagnostic text | fg: blue |
| DiagnosticHint | Hint diagnostic text | fg: cyan |
| DiagnosticOk | Success diagnostic text | fg: green |

## Mapping Summary (Old Vim to Tree-sitter)

| Old Vim group | Common Tree-sitter equivalent |
|---------------|-------------------------------|
| Comment | @comment |
| Constant | @constant / @number / @boolean |
| String | @string |
| Identifier | @variable / @field / @parameter |
| Function | @function / @function.call |
| Statement | @keyword / @conditional / @repeat |
| Type | @type |
| Operator | @operator |
| PreProc | @preproc (less common) |
| Special | @variable.builtin / @constant.builtin |

## ANSI Terminal Palette

The `terminal_palette` parameter provides the 16 ANSI colors the colorscheme stored in `vim.g.terminal_color_0` through `vim.g.terminal_color_15`. These are not a colorscheme's private palette, and an index does not belong to a particular highlight group. An unset global is nil. ColorSync does not fill it from a highlight.

| Index | Conventional ANSI role |
|-------|-------------------------|
| 0 | Black |
| 1 | Red |
| 2 | Green |
| 3 | Yellow |
| 4 | Blue |
| 5 | Magenta |
| 6 | Cyan |
| 7 | White |
| 8–15 | Bright variants of 0–7 |

When a generator lists an ANSI slot in a candidate chain, a nil slot is skipped and the next candidate is used. Ask for a highlight group when the color should follow a semantic role such as an error or a function name.

## Usage in Generators

Every generator receives two parameters:

1. **`highlights`**: A table of all highlight groups with their resolved colors
   - Access via: `highlights.Normal.fg`, `highlights.Function.bg`, etc.
   - Tree-sitter groups: `highlights['@string'].fg`, `highlights['@keyword'].fg`

2. **`terminal_palette`**: A table of 16 ANSI colors indexed 0-15
   - Access via: `terminal_palette[0]` through `terminal_palette[15]`

Generators also expose `describe(highlights, terminal_palette)`. Its entries contain the external target, semantic role, ordered candidates, selected source, value, and modifiers. Config generation and the visual report consume the same mapping definitions so they cannot drift.

### Example

```lua
function M.generate(highlights, terminal_palette)
  -- Use Normal foreground
  local fg = highlights.Normal.fg

  -- Use tree-sitter string color
  local string_color = highlights['@string'] and highlights['@string'].fg

  -- Use ANSI green
  local green = terminal_palette[2]

  -- With fallback chain
  local border = highlights['@function'] and highlights['@function'].fg
    or highlights.Function and highlights.Function.fg
    or terminal_palette[4]
end
```
