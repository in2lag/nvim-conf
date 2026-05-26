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
│   │   ├── diagnostics.lua  vim.diagnostic config + keymaps
│   │   ├── format.lua       conform.nvim (prettier, eslint_d, stylua)
│   │   ├── git.lua          gitsigns + diffview (tuned theme, q-close)
│   │   ├── indent.lua       mini.indentscope (animated scope guide)
│   │   ├── markdown.lua     render-markdown.nvim (in-buffer preview)
│   │   ├── numbers.lua      Hybrid line numbers + custom statuscolumn
│   │   ├── pairs.lua        mini.pairs (auto-close brackets/quotes)
│   │   ├── peek.lua         goto-preview (peek defs/refs in a float)
│   │   ├── search.lua       Search behavior + replace shortcut
│   │   ├── session.lua      auto-session (per-cwd session restore)
│   │   ├── statusline.lua   mini.statusline (global laststatus=3)
│   │   ├── surround.lua     mini.surround (sa/sd/sr text-object pairs)
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
   `markdown_inline`, `go`, `gomod`, `gosum`, `gowork`, `lua`, `vim`,
   `vimdoc`, `query`, `bash`, `json`, `yaml`, `toml`) install on first
   start via `tree-sitter-manager`. `.jsonc` files reuse the `json`
   parser via `vim.treesitter.language.register`.
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
| Statusline        | `mini.statusline` (from `mini.nvim`)     |
| Surround pairs    | `mini.surround` (from `mini.nvim`)       |
| Auto-pairs        | `mini.pairs` (from `mini.nvim`)          |
| Indent scope      | `mini.indentscope` (from `mini.nvim`)    |

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

Copilot is enabled in `gitcommit` buffers — running `git commit` (no
`-m`) opens nvim on `COMMIT_EDITMSG` with the staged diff visible as
comments, and Copilot drafts the subject line from that context.
Disabled in `gitrebase` and `help` to stay out of the way.

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

## Diagnostics

LSP diagnostics render in three places, configured in `lua/ui/diagnostics.lua`:

- **Sign column** (gutter): a `┃` bar colored by severity (red error,
  orange warn, etc.), matching the gitsigns shape so the gutter reads
  as two parallel colored bars. Severity-sorted so the worst issue wins
  each line.
  `signcolumn = "yes:2"` reserves two slots so gitsigns (left) and
  diagnostics (right) coexist without one hiding the other.
- **Virtual text** (end of line): the diagnostic message on every line
  that has a diagnostic, including the cursor line. The gitsigns blame
  is suppressed on lines that have a diagnostic so the two don't fight
  for the same eol slot:

  ```
  const foo = bar()    Cannot find name 'bar'                          ← broken line
  const ok  = 1        Petr, 14:32 • Add ok helper                     ← clean line
  ```

  Suppression is handled by a function `current_line_blame_formatter` in
  `lua/ui/git.lua` that returns an empty chunk list `{}` when
  `vim.diagnostic.get()` reports any diagnostic on the cursor line. A
  `DiagnosticChanged` autocmd triggers a synthetic `CursorMoved` so the
  blame re-evaluates as soon as the LSP catches up — no waiting for the
  next real cursor move.
- **Float** (`<leader>cd`): full message with source, rounded border.

`update_in_insert` is on — diagnostics refresh live while typing. LSP
servers (vtsls, gopls) debounce publishing internally, so you don't see a
new diagnostic on every keystroke.

| Key          | Action                                     |
| ------------ | ------------------------------------------ |
| `]d` / `[d`  | Next / prev diagnostic (Neovim default)    |
| `<C-W>d`     | Open diagnostic float (Neovim default)     |
| `<leader>cd` | Open diagnostic float at cursor            |
| `<leader>cq` | Project diagnostics in Telescope           |

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

## Surround Pairs (`mini.surround`)

Add, change, or delete surrounding characters (parens, quotes, tags, …)
around a text object. Standard `mini.surround` `s`-prefix:

| Key                       | Action                                          |
| ------------------------- | ----------------------------------------------- |
| `sa{motion}{char}`        | Surround **a**dd — e.g. `saiw)` wraps inner word in `()` |
| `sd{char}`                | Surround **d**elete — e.g. `sd)` removes the surrounding `()` |
| `sr{from}{to}`            | Surround **r**eplace — e.g. `sr"'` changes `"` to `'` |
| `sf{char}` / `sF{char}`   | Find next / previous surrounding character      |
| `sh{char}`                | Highlight the surrounding pair                  |
| `sa` (in visual)          | Wrap current selection                          |

Note: typing `s` alone (vim's substitute-character) now has a short
timeout-len delay while `mini.surround` waits to see if you're starting
`sa`/`sd`/`sr`. If you use `s` heavily, lower `timeoutlen` or use `cl`
instead (same effect, no delay).

## Auto-pairs (`mini.pairs`)

Typing `(`, `[`, `{`, `"`, `'`, `` ` `` inserts the matching closer with
the cursor between them. Hitting Enter inside `{}` opens a properly
indented block. Backspace over the opener also removes the closer.

## Indent Scope (`mini.indentscope`)

Draws a `┊` dotted guide marking the indent scope your cursor is in,
animated linearly over 80 ms on scope changes. Colored Frappé
a quiet mauve (`#82768e`, mauve × `Surface2`) so it picks up the same
hue family as the line numbers and markdown headings but stays muted
enough to disappear behind code. Disabled in `NvimTree`, `help`,
`markdown`, `terminal`, and Diffview buffers via a buffer-local
`miniindentscope_disable` flag.

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
| `<leader>E`  | Toggle tree sidebar (plain open/close)              |

## Git Keymaps

| Key          | Action                                       |
| ------------ | -------------------------------------------- |
| `]c` / `[c`  | Next / previous hunk (gitsigns)              |
| `<leader>gp` | Inline preview of the current hunk           |
| `<leader>gd` | Toggle Diffview (open / close)               |
| `<leader>gr` (in Diffview) | Revert file to base                |
| `q` (in Diffview) | Close Diffview                          |

Inline blame is on with `delay = 0` — the author, commit time, and
summary appear at end of line as soon as the cursor lands, with no
wait. Gitsigns caches blame per line so repeat hits are free. See the
Diagnostics section for how blame is suppressed on lines with a
diagnostic to avoid the two fighting for the same eol slot.

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
- `signcolumn = "yes:2"` so gitsigns and diagnostic signs each get a cell.
- `scrollopt = "ver,jump"` so Diffview's two windows stay synced vertically.
- Domain-specific opts (search case, completion popup, line numbers)
  live next to the feature they belong to under `lua/ui/`.

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

## Statusline

`mini.statusline` (from `mini.nvim`) — global statusline (`laststatus = 3`,
one bar across all splits) showing mode, git branch, filename + modified
flag, diagnostic counts (drawn from the same `vim.diagnostic` config as
the gutter), filetype + encoding, and cursor location. Uses
`nvim-web-devicons` for the filetype icon.

The wider `mini.nvim` package is installed as a single repo and unlocks
the rest of the family (`mini.surround`, `mini.pairs`, `mini.indentscope`,
etc.) via `require('mini.X').setup()` — no extra downloads needed when
adding more modules later.

## Sessions

`auto-session` saves on `:qa` per `cwd` and restores on entry when launched
without arguments. The previous active buffer list, splits, and cursor
positions come back; buffer-local options are *not* saved (so global
settings like indent width always win). The tree closes before save so the
layout doesn't carry a stale tree window. Suppressed for `~/`,
`~/Downloads`, `~/Desktop`, and `/`.
