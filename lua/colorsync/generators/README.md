# ColorSync Highlight Groups Reference

This document provides a reference for Neovim highlight groups that can be used when creating colorscheme generators.

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

## Color Palette (ANSI 16 Colors)

The `palette` parameter in generators provides access to the 16 ANSI terminal colors (0-15):

| Index | Color | Typical Highlight Group | Description |
|-------|-------|------------------------|-------------|
| 0 | Black | Normal.bg | Background color |
| 1 | Red | ErrorMsg.fg, DiffDelete | Error color |
| 2 | Green | String.fg, DiffAdd | Success/string color |
| 3 | Yellow | WarningMsg.fg, DiffChange | Warning color |
| 4 | Blue | Function.fg, Statement | Primary accent |
| 5 | Magenta | Keyword.fg, Type | Secondary accent |
| 6 | Cyan | Special.fg, Identifier | Tertiary accent |
| 7 | White | Normal.fg | Foreground color |
| 8 | Bright Black (Gray) | Comment.fg, LineNr | Dimmed text |
| 9 | Bright Red | ErrorMsg (bright) | Bright error |
| 10 | Bright Green | String (bright) | Bright string |
| 11 | Bright Yellow | Number | Bright warning |
| 12 | Bright Blue | Function (bright) | Bright primary |
| 13 | Bright Magenta | Keyword (bright) | Bright secondary |
| 14 | Bright Cyan | Special (bright) | Bright tertiary |
| 15 | Bright White | Normal (bright) | Bright foreground |

## Usage in Generators

When creating a generator, you receive two parameters:

1. **`highlights`**: A table of all highlight groups with their resolved colors
   - Access via: `highlights.Normal.fg`, `highlights.Function.bg`, etc.
   - Tree-sitter groups: `highlights['@string'].fg`, `highlights['@keyword'].fg`

2. **`palette`**: A table of 16 ANSI colors indexed 0-15
   - Access via: `palette[0]` through `palette[15]`

### Example

```lua
function M.generate(highlights, palette)
  -- Use Normal foreground
  local fg = highlights.Normal.fg
  
  -- Use tree-sitter string color
  local string_color = highlights['@string'] and highlights['@string'].fg
  
  -- Use palette green
  local green = palette[2]
  
  -- With fallback chain
  local border = highlights['@function'] and highlights['@function'].fg
    or highlights.Function and highlights.Function.fg
    or palette[4]
end
```
