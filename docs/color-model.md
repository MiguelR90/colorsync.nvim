# ColorSync Color Model

This guide explains which colors Neovim exposes, how ColorSync retrieves them, and how those values become themes for external tools.

## The Short Version

ColorSync can read two standardized color surfaces from Neovim:

1. **Highlight groups** describe semantic roles such as normal text, selections, errors, and functions.
2. **Terminal colors** provide the 16 ANSI colors used by terminal applications.

A colorscheme's own private palette is not standardized. Names such as `bg0`, `red`, or `aqua` exist only inside that colorscheme's implementation and cannot be retrieved generically.

```mermaid
flowchart LR
    privatePalette["Colorscheme private palette"]
    highlightDefinitions["Highlight definitions and links"]
    terminalGlobals["ANSI terminal globals 0–15"]
    colorData["ColorSync color snapshot"]
    mappings["Integration fallback mappings"]
    generatedFiles["fzf, Ghostty, Lazygit, WezTerm"]
    visualReport["Static visual report"]

    privatePalette --> highlightDefinitions
    privatePalette --> terminalGlobals
    highlightDefinitions --> colorData
    terminalGlobals --> colorData
    colorData --> mappings
    mappings --> generatedFiles
    colorData --> visualReport
    mappings --> visualReport
```

The two arrows from the private palette are important: highlights and ANSI colors are normally defined in parallel. Neovim does not derive one from the other. ColorSync only infers an ANSI color from a highlight when the colorscheme leaves that ANSI slot unset.

## Vocabulary

| Term | Meaning | Example |
|---|---|---|
| Private palette | Internal names chosen by one colorscheme | `bg0`, `orange`, `aqua` |
| Highlight group | A semantic Neovim style | `Normal`, `Visual`, `DiagnosticError`, `@function` |
| Highlight link | A group that inherits another group's style | `@function.call` → `Function` |
| Resolved highlight | Final colors and modifiers after following links | `fg = #a7c080`, `bold = true` |
| ANSI terminal palette | Sixteen conventional terminal color slots | `terminal_color_0` through `terminal_color_15` |
| Integration target | A tool-specific theme setting | Lazygit's `activeBorderColor` |

## How Highlights Are Retrieved

[`lua/colorsync/color_data.lua`](../lua/colorsync/color_data.lua) asks Neovim for every registered highlight name using:

```lua
vim.fn.getcompletion('', 'highlight')
```

It then makes two API calls for every group:

```lua
vim.api.nvim_get_hl(0, { name = name, link = true })
vim.api.nvim_get_hl(0, { name = name, link = false })
```

```mermaid
flowchart TD
    groupName["Highlight group name"]
    directQuery["Query with link = true"]
    resolvedQuery["Query with link = false"]
    definition["Direct definition or link target"]
    resolved["Resolved fg, bg, sp, and modifiers"]
    snapshot["Color snapshot"]

    groupName --> directQuery
    groupName --> resolvedQuery
    directQuery --> definition
    resolvedQuery --> resolved
    definition --> snapshot
    resolved --> snapshot
```

- `link = true` preserves a link such as `@function.call → Function`.
- `link = false` follows that link and returns the final style generators can use.
- `fg`, `bg`, and `sp` numeric RGB values are normalized to lowercase `#rrggbb`.
- Modifiers such as `bold`, `italic`, `underline`, `reverse`, and `blend` remain attributes rather than being treated as colors.

ColorSync stores both views because they answer different questions:

- Generators need the **resolved value**.
- The report needs the **original relationship** to explain where that value came from.

### Example Link Resolution

```mermaid
flowchart LR
    treeSitterCall["@function.call"]
    functionGroup["Function"]
    finalStyle["fg #a7c080"]

    treeSitterCall -->|"link"| functionGroup
    functionGroup -->|"resolved style"| finalStyle
```

The exact groups and values depend on the active colorscheme and installed plugins.

## How the ANSI Palette Is Retrieved

ColorSync first reads the globals set by the active colorscheme:

```lua
vim.g.terminal_color_0
vim.g.terminal_color_1
-- through terminal_color_15
```

Each resulting entry records both its value and its provenance.

```mermaid
flowchart TD
    slot["ANSI slot N"]
    globalCheck{"terminal_color_N exists?"}
    explicit["Use explicit terminal color"]
    fallbackCheck["Try ordered highlight fallbacks"]
    inferred["Use first available highlight color"]
    unset["Record slot as unset"]

    slot --> globalCheck
    globalCheck -->|Yes| explicit
    globalCheck -->|No| fallbackCheck
    fallbackCheck -->|Found| inferred
    fallbackCheck -->|None| unset
```

For example, ANSI green at index 2 uses:

1. `vim.g.terminal_color_2`
2. `String.fg`
3. `DiffAdd.fg`
4. `DiagnosticOk.fg`
5. unset

The highlight fallback is a ColorSync inference, not a rule imposed by Neovim. The visual report labels every ANSI slot as explicit, inferred, or unset.

## The Captured Snapshot

`require('colorsync.color_data').capture()` returns one snapshot:

```text
colorscheme
highlights
  GroupName
    resolved attributes
highlight_definitions
  GroupName
    direct attributes or link
highlight_names
terminal_palette
  indexes 0 through 15
terminal_sources
  explicit, inferred, or unset provenance
```

[`lua/colorsync/init.lua`](../lua/colorsync/init.lua) captures this data once per synchronization and passes the resolved highlights and terminal palette to every generator.

## How Integration Mappings Work

[`lua/colorsync/mapping.lua`](../lua/colorsync/mapping.lua) provides four kinds of candidates:

| Candidate | Meaning |
|---|---|
| Highlight | A group attribute such as `Visual.bg` |
| Terminal | An ANSI slot such as `terminal_color_4` |
| Literal | A tool keyword or final hardcoded fallback |
| Derived | A computed value, such as contrast-selected text |

Each external target has an ordered candidate list. The first candidate with a value wins.

```mermaid
flowchart LR
    target["External target"]
    first["Candidate 1"]
    second["Candidate 2"]
    third["Candidate 3"]
    selected["First available value"]

    target --> first
    first -->|"unset"| second
    second -->|"unset"| third
    first -->|"available"| selected
    second -->|"available"| selected
    third -->|"available"| selected
```

Every generator exposes the same two operations:

- `describe(highlights, terminal_palette)` returns targets, semantic roles, candidates, selected sources, values, and modifiers.
- `generate(highlights, terminal_palette)` formats those described mappings for the external tool.

```mermaid
flowchart TD
    snapshot["Color snapshot"]
    describe["Generator describe"]
    mappingRows["Mapping records"]
    generate["Generator generate"]
    config["Tool configuration"]
    reportRenderer["HTML report renderer"]
    report["Searchable visual report"]

    snapshot --> describe
    describe --> mappingRows
    mappingRows --> generate
    generate --> config
    mappingRows --> reportRenderer
    snapshot --> reportRenderer
    reportRenderer --> report
```

This shared source of truth prevents the report from claiming one mapping while the generated configuration uses another.

## Current Integration Strategies

| Integration | Main sources | Examples |
|---|---|---|
| fzf | `Normal` plus ANSI colors | foreground from `Normal.fg`, prompt from ANSI green |
| Ghostty | `Normal`, `Cursor`, `Visual`, and all ANSI slots | terminal background, cursor colors, complete palette |
| WezTerm | `Normal`, `Cursor`, `Visual`, and all ANSI slots | Lua color table with ANSI and bright arrays |
| Lazygit | Semantic UI, diagnostic, diff, and selection highlights | borders, selected lines, commit markers, unstaged changes |

### Lazygit Example

Lazygit's active border uses the first available candidate:

```mermaid
flowchart LR
    target["activeBorderColor"]
    info["DiagnosticInfo.fg"]
    title["Title.fg"]
    tsFunction["@function.fg"]
    functionGroup["Function.fg"]
    ansiBlue["ANSI 4"]
    ansiBrightBlue["ANSI 12"]

    target --> info --> title --> tsFunction --> functionGroup --> ansiBlue --> ansiBrightBlue
```

The generated value also receives the `bold` modifier.

Commit marker backgrounds use success or warning colors. Their foreground is computed by comparing the contrast of `Normal.fg` and `Normal.bg` against that chosen background and selecting the more readable one.

## Generate and Use the Visual Report

Generate a report for an installed colorscheme:

```sh
just color-report everforest
```

Open the resulting file:

```sh
open build/colorsync-everforest.html
```

Choose a custom output path with the second argument:

```sh
just color-report tokyonight /tmp/tokyonight-colors.html
```

The report contains:

- the four-layer color model;
- all 16 ANSI swatches and their provenance;
- every highlight group with search and category filters;
- direct links and fully resolved colors;
- style modifiers and rendered previews;
- all integration targets, selected sources, fallback chains, and final swatches.

The report is self-contained: its CSS and JavaScript are embedded, and it does not load external assets.

## File Guide

| File | Responsibility |
|---|---|
| [`lua/colorsync/color_data.lua`](../lua/colorsync/color_data.lua) | Capture and normalize highlights and ANSI colors |
| [`lua/colorsync/mapping.lua`](../lua/colorsync/mapping.lua) | Represent fallback candidates and select values |
| [`lua/colorsync/generators/`](../lua/colorsync/generators/) | Describe mappings and format external configurations |
| [`lua/colorsync/report.lua`](../lua/colorsync/report.lua) | Render the standalone visual report |
| [`scripts/generate-color-report.lua`](../scripts/generate-color-report.lua) | Load a colorscheme and write the report |
| [`lua/colorsync/init.lua`](../lua/colorsync/init.lua) | Capture once and run all generators during sync |

