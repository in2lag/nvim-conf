# Neovim Configuration

Personal Neovim setup. Built on Neovim 0.12+ using the built-in `vim.pack`
package manager (no `lazy.nvim`, no `packer`). Modular Lua under `lua/core`,
`lua/ui`, and `lua/ai`.

## Layout

```
.
├── init.lua                 Entry point: plugin list, LSP, theme, requires
├── nvim-pack-lock.json      vim.pack lockfile (pinned plugin revisions)
├── lua/
│   ├── core/
│   │   ├── keymaps.lua      Leader, clipboard, editing, smart Home
│   │   ├── lsp.lua          LSP server config (vtsls, gopls, svelte)
│   │   ├── options.lua      Global opts (indent=2, termguicolors, listchars)
│   │   └── treesitter.lua   tree-sitter-manager + parser list
│   ├── ui/
│   │   ├── completion.lua   blink.cmp (LSP, buffer, path, snippets)
│   │   ├── format.lua       conform.nvim (prettier, eslint_d, stylua)
│   │   ├── git.lua          gitsigns + diffview (tuned theme, q-close)
│   │   ├── markdown.lua     render-markdown.nvim (in-buffer preview)
│   │   ├── numbers.lua      Hybrid line numbers + custom statuscolumn
│   │   ├── peek.lua         goto-preview (peek defs/refs in a float)
│   │   ├── search.lua       Search behavior + replace shortcut
│   │   ├── session.lua      auto-session (per-cwd session restore)
│   │   ├── tree.lua         nvim-tree with smart toggle
│   │   └── whichkey.lua     which-key prompt for leader bindings
│   └── ai/
│       └── copilot.lua      copilot.lua (ghost-text suggestions)
```

## Quick Start

1. Clone into `~/.config/nvim`.
2. Launch `nvim`. `vim.pack` resolves plugins from `nvim-pack-lock.json` on
   first run and clones them into the pack directory.
3. Tree-sitter parsers listed in `lua/core/treesitter.lua` (`typescript`,
   `tsx`, `javascript`, `svelte`, `html`, `css`, `markdown`,
   `markdown_inline`, `go`, `gomod`, `gosum`, `gowork`) install on first
   start via `tree-sitter-manager`.
4. Run `:Copilot auth` once to authorize GitHub Copilot.
5. The leader key is `<Space>`.

## At a Glance

| Area              | Plugin / Mechanism                       |
| ----------------- | ---------------------------------------- |
| Package manager   | `vim.pack` (built-in, Neovim 0.12+)      |
| Theme             | `catppuccin/nvim` (Frappé flavour)       |
| Fuzzy finder      | `telescope.nvim` + `plenary.nvim`        |
| File tree         | `nvim-tree.lua` + `nvim-web-devicons`    |
| Git: signs        | `gitsigns.nvim`                          |
| Git: diff view    | `diffview.nvim`                          |
| LSP               | `nvim-lspconfig` + `vtsls`, `gopls`, `svelte` |
| Tree-sitter       | `tree-sitter-manager.nvim`               |
| Completion menu   | `blink.cmp` (Lua fuzzy matcher)          |
| AI suggestions    | `copilot.lua` (ghost text)               |
| Peek / preview    | `goto-preview`                           |
| Sessions          | `auto-session` (per-cwd auto save)       |
| Formatter         | `conform.nvim`                           |
| Leader hints      | `which-key.nvim`                         |
| Markdown preview  | `render-markdown.nvim` (in-buffer)       |
| Rainbow brackets  | `rainbow-delimiters.nvim` (tree-sitter)  |

## Completion & AI Keymaps

`blink.cmp` drives the completion menu; `copilot.lua` shows full-line ghost
text. Both render simultaneously (VSCode-style): the menu is a floating
window, Copilot is inline virt_text, so they don't fight for the same space.
The first menu item is preselected (highlighted but not inserted) so `<Tab>`
always has a target.

| Key                | Action                                                       |
| ------------------ | ------------------------------------------------------------ |
| `<Tab>`            | Accept menu item → jump snippet → accept Copilot → real tab  |
| `<S-Tab>`          | Jump snippet backward → select previous menu item            |
| `<CR>`             | Accept selected menu item                                    |
| `<C-n>` / `<C-p>`  | Cycle menu next / prev                                       |
| `<Esc>`            | Hide menu (stay in insert; Copilot ghost text stays)         |
| `<C-e>`            | Cancel menu                                                  |
| `<M-l>`            | Always-on Copilot accept                                     |
| `<M-Right>`        | Accept next word from Copilot                                |
| `<M-]>` / `<M-[>`  | Cycle Copilot alternatives                                   |
| `<C-]>`            | Dismiss Copilot ghost text                                   |

## Peek Keymaps (`goto-preview`)

Float window over the current buffer with the requested LSP info.

| Key   | Action                                            |
| ----- | ------------------------------------------------- |
| `gpd` | Peek definition                                   |
| `gpi` | Peek implementation                               |
| `gpt` | Peek type definition                              |
| `gpr` | Peek references (Telescope picker)                |
| `gpc` | Close all peek windows                            |
| `q` / `<Esc>` (in float) | Close the peek                     |
| `<CR>` (in float)        | Promote peek to full buffer         |

`svelte-language-server` runs on `.svelte` buffers so peek/refs work from
inside Svelte components. `vtsls` is configured with `typescript-svelte-plugin`
as a global TS server plugin, so references on a TS symbol also surface
usages from `.svelte` files. Both packages live in the global npm prefix.

## Editing Keymaps

| Key          | Action                                       |
| ------------ | -------------------------------------------- |
| `u`          | Undo (default)                               |
| `U`          | Redo (replaces default "undo line")          |
| `<leader>d`  | Duplicate line / selection                   |
| `<leader>y`  | Yank to system clipboard                     |
| `<leader>v`  | Paste from system clipboard                  |
| `<leader>P`  | Paste over selection without losing yank     |
| `<leader>x`  | Black-hole delete (no clobber of yank)       |

## Find / Search Keymaps (Telescope)

| Key                  | Action                                       |
| -------------------- | -------------------------------------------- |
| `<leader><leader>`   | Find files                                   |
| `<leader>ff`         | Find files                                   |
| `<leader>p`          | Project text search (live grep)              |
| `<leader>fg`         | Live grep                                    |
| `<leader>b`          | Find buffer                                  |
| `<leader>fb`         | Find buffer                                  |
| `<leader>fr`         | Recent files                                 |
| `<leader>sr`         | Search & replace word under cursor (in file) |
| `<C-d>` / `dd` in buffers picker | Delete the highlighted buffer    |

`find_files` and `live_grep` include hidden files; `.git/` is excluded.
`.gitignore` is honored via ripgrep's defaults.

## File Tree

`nvim-tree` opens on the left at 50 columns. The `.git/` directory is
filtered out of the listing.

| Key          | Action                                              |
| ------------ | --------------------------------------------------- |
| `<leader>e`  | Open tree → focus tree → jump back to code (toggle) |
| `<leader>E`  | Close tree sidebar                                  |

## Git Keymaps

| Key          | Action                                       |
| ------------ | -------------------------------------------- |
| `]c` / `[c`  | Next / previous hunk (gitsigns)              |
| `<leader>gp` | Inline preview of the current hunk           |
| `<leader>gd` | Toggle Diffview (open / close)               |
| `<leader>gr` (in Diffview) | Revert file to base                |
| `q` (in Diffview) | Close Diffview                          |

`DiffAdd`/`DiffDelete`/`DiffChange`/`DiffText` are overridden in
`lua/ui/git.lua` with muted Frappé-tinted backgrounds so diffs read
quietly — the inline word-diff (`DiffText`) is a slightly brighter green
than `DiffAdd` but no longer bold. Re-applied on every `ColorScheme`.

## Editor Defaults

Set in `lua/core/options.lua`:

- 2-space indentation (`tabstop`/`shiftwidth`/`softtabstop` = 2, `expandtab`).
- `termguicolors` for true-color UI.
- Gentle whitespace visualization via `list` + `listchars`:
  `›` for tabs, `·` for leading and trailing spaces, `␣` for non-breaking space.
- Terminal/window title set to `nvim - <project>` (basename of `cwd`) via
  `title` + `titlestring`.
- Domain-specific opts (search case, completion popup, line numbers,
  diff scroll sync) live next to the feature they belong to under `lua/ui/`.

## Markdown

`render-markdown.nvim` renders Markdown directly inside the buffer using
treesitter virtual text — code fences get a background + language label,
lists/checkboxes use proper symbols, tables align. The line under the
cursor falls back to raw markup while you're editing it.

Headings have no icons or background bars — just bold text in a distinct
Catppuccin-Frappé color per level (H1 red → H2 peach → H3 yellow → H4 green
→ H5 blue → H6 mauve). Colors are applied by overriding the treesitter
heading captures (`@markup.heading.N.markdown`) on every `ColorScheme`,
so the colorscheme load order doesn't wipe them.

Bullet lists use a single filled circle (`●`) at every depth, but the color
cycles per nesting level (blue → green → peach → mauve). Checkboxes are
colored too: unchecked is yellow, checked is green. Inline link labels are
underlined; the per-domain link icons (Google, GitHub, etc.) are disabled
so labels read cleanly.

| Key          | Action                       |
| ------------ | ---------------------------- |
| `<leader>mp` | Toggle Markdown rendering    |

`blink.cmp` is disabled in markdown buffers so the completion menu doesn't
fight with the prose flow. Copilot ghost text still works, and `<Tab>` is
remapped buffer-locally in markdown to accept the suggestion (or insert a
real tab if no suggestion is visible). Markdown is formatted with `prettier`
via `conform.nvim` on save.

## Sessions

`auto-session` saves on `:qa` per `cwd` and restores on entry when launched
without arguments. The previous active buffer list, splits, and cursor
positions come back; buffer-local options are *not* saved (so global
settings like indent width always win). The tree closes before save so the
layout doesn't carry a stale tree window. Suppressed for `~/`,
`~/Downloads`, `~/Desktop`, and `/`.
