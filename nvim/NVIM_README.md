# Neovim keymap prefixes

The "wait-and-see" hint menus (via **which-key**) appear for any key that is a
*prefix* of several mappings. This is a map of those prefixes in this config.

> Discover interactively: press a prefix and wait, or run `:Telescope keymaps`
> to fuzzy-search every mapping with its description.

## LSP / code navigation

| Keys        | Action                      | Use for                                                                                     |
|-------------|-----------------------------|---------------------------------------------------------------------------------------------|
| `<Space>ss` | Workspace Symbols (dynamic) | Find any struct/enum/trait/fn across the whole project — type the name, fuzzy-search. The main one for "find a type." |
| `<Space>ds` | Document Symbols            | List all types/fns in the current file                                                      |
| `<Space>D`  | Type Definition             | Jump to the type of the symbol under the cursor                                             |
| `gd`        | Goto Definition             | Jump to where the symbol under cursor is defined                                            |
| `gi`        | Goto Implementation         | Jump to trait impls                                                                          |
| `gD`        | Goto Declaration            |                                                                                             |
| `grr`       | Goto References             | Find all usages                                                                             |
| `K`         | Hover docs                  | Show type/signature inline                                                                   |

## Custom prefixes — all under `<leader>` (Space)

`<leader>` is the hub; these are its real sub-groups:

| Prefix       | Group             | Members                                                                 |
|--------------|-------------------|-------------------------------------------------------------------------|
| `<leader>c`  | **Claude Code**   | `cc cr cC cf cs cb cy cn`                                               |
| `<leader>g`  | **git**           | `gd` Diffview · `gh`/`ga` history · `gp`/`gn` hunks · `gm` messenger · `gg` reload theme |
| `<leader>t`  | **tabs & toggles**| `tn` new · `tc` close · `tr` rename · `tw` wrap                          |
| `<leader>e`  | **edit/open file**| `e` new-adjacent · `es` snippets                                         |
| `<leader>h`  | **git hunk**      | `hj` preview                                                             |

Single-shot leaders (not menus): `w` save · `q` close buffer · `r` replace-word ·
`j` JSON-pretty · `i` indent-file · `o`/`O` blank line · `p` paste-no-yank · `m`
replace-to-`_` · `;` buffers · `,` invisibles · `S` grep · `F`/`P` copy paths ·
`<leader><leader>` buffer toggle.

## Built-in Vim/Neovim prefixes (which-key hints these too)

- **`g`** — goto/misc: `gd`/`gi`/`gD` goto, `gx` open URL, `gc`/`gcc` comment
  (vim-commentary), `gO` doc symbols, plus native `gg`, `gU`, `g~`, `g;`…
- **`gr`** — Neovim's built-in **LSP** menu: `grn` rename, `gra` code-action,
  `gri` implementation, `grt` type-def, `grr` references, `grx` codelens
- **`z`** — folds & scroll/cursor positioning (`za zz zt zb zf`…)
- **`[` / `]`** — previous / next navigation (diagnostics, quickfix, brackets,
  methods; plugins add more)
- **`<C-w>`** — windows (splits, resize, move) + `<C-w>d` diagnostics
- **`"`** registers · **`` ` ``**/**`'`** marks · **`@`** macros

## Plugin operator-prefixes (act on a motion, not a menu)

- **`ys` / `cs` / `ds`** — vim-surround (add/change/delete surroundings), `yss`
- **`gc`** — vim-commentary (`gcc` line, `gc{motion}`)

## Caveat

Many **LSP and filetype maps are buffer-local** — they only exist once a language
server attaches or in a specific filetype, so a scratch buffer shows fewer hints
than a real `.rs`/`.lua` file.
