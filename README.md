# Neovim Configuration

Personal Neovim setup. Built on Neovim 0.12+ using the built-in `vim.pack`
package manager (no `lazy.nvim`, no `packer`). Modular Lua under `lua/core`,
`lua/ui`, `lua/debug`, and `lua/ai`.

## Layout

```
.
├── init.lua                 Entry point: plugin list, LSP, theme, requires
├── nvim-pack-lock.json      vim.pack lockfile (pinned plugin revisions)
├── lua/
│   ├── core/
│   │   ├── keymaps.lua      Leader, clipboard, editing, save (Cmd+S), smart Home
│   │   ├── lsp.lua          LSP server config (vtsls, gopls, svelte, angularls)
│   │   ├── options.lua      Global opts (indent=2, termguicolors, listchars)
│   │   └── treesitter.lua   tree-sitter-manager + parser list
│   ├── debug/
│   │   └── dap.lua          nvim-dap + dap-ui (Go via delve, JS/TS via vscode-js-debug)
│   ├── ui/
│   │   ├── completion.lua   blink.cmp (LSP, buffer, path, snippets)
│   │   ├── cursorline.lua   Cursorline only in focused window, outside insert
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
│   │   ├── smear.lua        smear-cursor.nvim (animated cursor smear)
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
   `tsx`, `javascript`, `svelte`, `angular`, `html`, `css`, `markdown`,
   `markdown_inline`, `go`, `gomod`, `gosum`, `gowork`, `lua`, `vim`,
   `vimdoc`, `query`, `bash`, `json`, `yaml`, `toml`) install on first
   start via `tree-sitter-manager`. `.jsonc` files reuse the `json`
   parser via `vim.treesitter.language.register`; `*.component.html` files are
   detected as the `htmlangular` filetype and highlighted with the `angular`
   parser (see the Angular section).
4. Run `:Copilot auth` once to authorize GitHub Copilot.
5. Optional, for debugging: Go needs `dlv` on `$PATH`; JS/TS needs
   Microsoft's `vscode-js-debug` installed manually so that
   `~/.local/share/nvim/js-debug/src/dapDebugServer.js` exists.
6. The leader key is `<Space>`.

Plugins are pinned to **exact commit revisions** in both `init.lua` (each
spec's `version = "<sha>"`) and `nvim-pack-lock.json`, so installs are
reproducible across machines. To bump one: change its `version` in `init.lua`,
`:restart`, then `:lua vim.pack.update({ '<name>' })` and confirm the preview
buffer with `:write`. A plain `:lua vim.pack.update()` is otherwise a no-op
since nothing floats.

## At a Glance

| Area             | Plugin / Mechanism                                      |
| ---------------- | ------------------------------------------------------- |
| Package manager  | `vim.pack` (built-in, Neovim 0.12+)                     |
| Theme            | `catppuccin/nvim` (Frappé flavour)                      |
| Fuzzy finder     | `telescope.nvim` + `plenary.nvim`                       |
| File tree        | `nvim-tree.lua` + `nvim-web-devicons`                   |
| Git: signs       | `gitsigns.nvim`                                         |
| Git: diff view   | `diffview.nvim`                                         |
| LSP              | `nvim-lspconfig` + `vtsls`, `gopls`, `svelte`, `angularls` |
| Debugging        | `nvim-dap` + `nvim-dap-ui`, `nvim-dap-go`, virtual text |
| Tree-sitter      | `tree-sitter-manager.nvim`                              |
| Completion menu  | `blink.cmp` (Lua fuzzy matcher)                         |
| AI suggestions   | `copilot.lua` (ghost text)                              |
| Peek / preview   | `goto-preview`                                          |
| Sessions         | `auto-session` (per-cwd auto save)                      |
| Formatter        | `conform.nvim`                                          |
| Leader hints     | `which-key.nvim`                                        |
| Markdown preview | `render-markdown.nvim` (in-buffer)                      |
| Rainbow brackets | `rainbow-delimiters.nvim` (tree-sitter)                 |
| Statusline       | `mini.statusline` (from `mini.nvim`)                    |
| Surround pairs   | `mini.surround` (from `mini.nvim`)                      |
| Auto-pairs       | `mini.pairs` (from `mini.nvim`)                         |
| Indent scope     | `mini.indentscope` (from `mini.nvim`)                   |
| Cursor smear     | `smear-cursor.nvim`                                     |

## Completion & AI Keymaps

`blink.cmp` drives the completion menu; `copilot.lua` shows full-line ghost
text. Both render simultaneously (VSCode-style): the menu is a floating
window, Copilot is inline virt_text, so they don't fight for the same space.
The first menu item is preselected (highlighted but not inserted). `<Tab>`
prefers a visible Copilot suggestion; when Copilot has nothing it accepts the
menu item, so use `<CR>` to take a menu item while Copilot is showing.

| Key               | Action                                                      |
| ----------------- | ----------------------------------------------------------- |
| `<Tab>`           | Accept Copilot → accept menu item → jump snippet → real tab |
| `<S-Tab>`         | Jump snippet backward → select previous menu item           |
| `<CR>`            | Accept selected menu item                                   |
| `<C-n>` / `<C-p>` | Cycle menu next / prev                                      |
| `<Esc>`           | Hide menu (stay in insert; Copilot ghost text stays)        |
| `<C-e>`           | Cancel menu                                                 |
| `<M-l>`           | Always-on Copilot accept                                    |
| `<M-Right>`       | Accept next word from Copilot                               |
| `<M-]>` / `<M-[>` | Cycle Copilot alternatives                                  |
| `<C-]>`           | Dismiss Copilot ghost text                                  |

Copilot is enabled in `gitcommit` buffers — running `git commit` (no
`-m`) opens nvim on `COMMIT_EDITMSG` with the staged diff visible as
comments, and Copilot drafts the subject line from that context.
Disabled in `gitrebase` and `help` to stay out of the way.

## Peek Keymaps (`goto-preview`)

Float window over the current buffer with the requested LSP info.

| Key               | Action                             |
| ----------------- | ---------------------------------- |
| `gpd`             | Peek definition                    |
| `gpi`             | Peek implementation                |
| `gpt`             | Peek type definition               |
| `gpr`             | Peek references (Telescope picker) |
| `gpc`             | Close all peek windows             |
| `q` (in float)    | Close this peek window             |
| `Q` (in float)    | Close all peek windows             |
| `<CR>` (in float) | Promote peek to full buffer        |

`svelte-language-server` runs on `.svelte` buffers so peek/refs work from
inside Svelte components. `vtsls` is configured with `typescript-svelte-plugin`
as a global TS server plugin, so references on a TS symbol also surface
usages from `.svelte` files. Both packages live in the global npm prefix.

## Angular

`angularls` (the Angular Language Service — install once with
`npm i -g @angular/language-server`) provides template intelligence:
completion, go-to-definition, and find-references for bindings/variables
inside `.html` / `.component.html` templates, plus template diagnostics.

It is restricted to the `html` and `htmlangular` filetypes in
`lua/core/lsp.lua` and deliberately does **not** attach to `.ts` files.
`vtsls` already owns those, and letting both attach doubles completions and
diagnostics and breaks `goto-preview`: a references request fans out to every
attached client, so `gpr` opened duplicate windows. The Angular server still
reads the whole TypeScript project from disk, so template intelligence is
unaffected — only inline templates written as a string inside a `.ts`
component lose Angular-aware features (the TypeScript itself is still handled
by `vtsls`).

Template highlighting uses the `angular` tree-sitter parser:
`*.component.html` is detected as the `htmlangular` filetype via
`vim.filetype.add`, the parser is registered for it, and a `FileType` autocmd
starts treesitter — needed because `tree-sitter-manager` keys its
auto-highlight off parser names, not the `htmlangular` filetype. Templates are
formatted with `prettier` via `conform.nvim` (the `htmlangular` filetype is
mapped to prettier in `lua/ui/format.lua`).

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

Document highlight: when the cursor rests on a symbol for `updatetime`
(100 ms), all other references of that symbol in the buffer get a subtle
highlight (`vim.lsp.buf.document_highlight`), cleared on cursor move.
Enabled per buffer on `LspAttach` for servers that support it.

| Key          | Action                                  |
| ------------ | --------------------------------------- |
| `]d` / `[d`  | Next / prev diagnostic (Neovim default) |
| `<C-W>d`     | Open diagnostic float (Neovim default)  |
| `<leader>cd` | Open diagnostic float at cursor         |
| `<leader>cq` | Project diagnostics in Telescope        |

## Editing Keymaps

| Key                       | Action                                             |
| ------------------------- | -------------------------------------------------- |
| `<leader>D`               | Duplicate line / selection                         |
| `<leader>o` / `<leader>O` | Insert blank line(s) below / above (takes a count) |
| `<leader>y`               | Yank to system clipboard                           |
| `<leader>v`               | Paste from system clipboard                        |
| `<leader>P`               | Paste over selection without losing yank           |
| `<leader>x`               | Black-hole delete (no clobber of yank)             |
| `L` / `H`                 | Next / previous buffer                             |
| `<D-s>` (Cmd+S)           | Save file — normal, insert, and visual modes       |

`<D-s>` is Cmd+S: Ghostty forwards `Cmd+S` to nvim as `<D-s>` over the kitty
keyboard protocol, and it's mapped with `<cmd>write` so it saves without
leaving your current mode (you stay in insert / visual). Defined in
`lua/core/keymaps.lua`.

## Surround Pairs (`mini.surround`)

Add, change, or delete surrounding characters (parens, quotes, tags, …)
around a text object. Standard `mini.surround` `s`-prefix:

| Key                     | Action                                                        |
| ----------------------- | ------------------------------------------------------------- |
| `sa{motion}{char}`      | Surround **a**dd — e.g. `saiw)` wraps inner word in `()`      |
| `sd{char}`              | Surround **d**elete — e.g. `sd)` removes the surrounding `()` |
| `sr{from}{to}`          | Surround **r**eplace — e.g. `sr"'` changes `"` to `'`         |
| `sf{char}` / `sF{char}` | Find next / previous surrounding character                    |
| `sh{char}`              | Highlight the surrounding pair                                |
| `sa` (in visual)        | Wrap current selection                                        |

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

## Cursor (`smear-cursor.nvim`)

The cursor smears toward its target in real time (Neovide-style), making
jumps easy to follow. Configured in `lua/ui/smear.lua`. `smear_insert_mode`
is off so typing stays crisp — the smear only fires on navigation moves.
Feel is tuned via `stiffness` / `trailing_stiffness` (lower = longer smear)
and `damping`; `:SmearCursorToggle` turns it on/off live. If the smear
glyphs look blocky, set `legacy_computing_symbols_support = true` (needs a
font with octant/legacy-computing symbols).

## Find / Search Keymaps (Telescope)

| Key                              | Action                                       |
| -------------------------------- | -------------------------------------------- |
| `<leader><leader>`               | Find files                                   |
| `<leader>p`                      | Live grep the project                        |
| `<leader>fb`                     | Find buffers                                 |
| `<leader>sw` (normal)            | Grep word under cursor (project-wide)        |
| `<leader>sw` (visual)            | Grep the current selection (project-wide)    |
| `<leader>sr`                     | Search & replace word under cursor (in file) |
| `<C-d>` / `dd` in buffers picker | Delete the highlighted buffer                |

`find_files` and `live_grep` include hidden files; `.git/` is excluded.
`.gitignore` is honored via ripgrep's defaults. Image files (`png`,
`jpg`, `gif`, `svg`, `webp`, `ico`, …) are hidden from every picker via
`file_ignore_patterns` in the Telescope defaults.

## File Tree

`nvim-tree` opens on the left at 50 columns. The `.git/` directory is
filtered out of the listing.

| Key         | Action                                              |
| ----------- | --------------------------------------------------- |
| `<leader>e` | Open tree → focus tree → jump back to code (toggle) |
| `<leader>E` | Toggle tree sidebar (plain open/close)              |

## Git Keymaps

| Key                        | Action                              |
| -------------------------- | ----------------------------------- |
| `]c` / `[c`                | Next / previous hunk (gitsigns)     |
| `<leader>gp`               | Inline preview of the current hunk  |
| `<leader>gs`               | Changed files in a Telescope picker |
| `<leader>gd`               | Toggle Diffview (open / close)      |
| `<leader>gr` (in Diffview) | Revert file to base                 |
| `<leader>gf` (in Diffview) | Open file in editor, close Diffview |
| `q` (in Diffview)          | Close Diffview                      |

Inline blame is on with `delay = 0` — the author, commit time, and
summary appear at end of line as soon as the cursor lands, with no
wait. Gitsigns caches blame per line so repeat hits are free. See the
Diagnostics section for how blame is suppressed on lines with a
diagnostic to avoid the two fighting for the same eol slot.

`DiffAdd`/`DiffDelete`/`DiffChange`/`DiffText` are overridden in
`lua/ui/git.lua` with muted Frappé-tinted backgrounds so diffs read
quietly — the inline word-diff (`DiffText`) is a slightly brighter green
than `DiffAdd` but no longer bold. Re-applied on every `ColorScheme`.

## Debugging (nvim-dap)

`nvim-dap` with `nvim-dap-ui` (opens automatically on launch/attach,
closes when the session ends) and `nvim-dap-virtual-text` for inline
variable values. Configured in `lua/debug/dap.lua`.

Adapters:

- **Go** — `nvim-dap-go` wraps Delve (`dlv` on `$PATH`); includes
  debug-nearest-test and attach.
- **JS / TS / Svelte** — Microsoft's `vscode-js-debug` (`pwa-node`,
  `pwa-chrome`), expected under `~/.local/share/nvim/js-debug/`. Launch
  current file with Node, attach to a process, or launch Chrome against
  `localhost:5173` (Vite/Svelte dev server).

| Key          | Action                    |
| ------------ | ------------------------- |
| `<leader>db` | Toggle breakpoint         |
| `<leader>dB` | Conditional breakpoint    |
| `<leader>dc` | Continue / start          |
| `<leader>do` | Step over                 |
| `<leader>di` | Step into                 |
| `<leader>dO` | Step out                  |
| `<leader>dl` | Run last                  |
| `<leader>dr` | Toggle REPL               |
| `<leader>du` | Toggle DAP UI             |
| `<leader>de` | Evaluate expression (n/v) |
| `<leader>dq` | Terminate session         |
| `<leader>dt` | Debug nearest Go test     |

## Editor Defaults

Set in `lua/core/options.lua`:

- 2-space indentation (`tabstop`/`shiftwidth`/`softtabstop` = 2, `expandtab`).
- `termguicolors` for true-color UI.
- Gentle whitespace visualization via `list` + `listchars`:
  `›` for tabs, `·` for leading and trailing spaces, `␣` for non-breaking space.
- Terminal/window title set to `<project> - nvim` (basename of `cwd`) via
  `title` + `titlestring`.
- `signcolumn = "yes:2"` so gitsigns and diagnostic signs each get a cell.
- `scrollopt = "ver,jump"` so Diffview's two windows stay synced vertically.
- `updatetime = 100` so `CursorHold` fires quickly (drives the LSP
  document highlight).
- Cursorline only in the focused window and outside insert mode
  (`lua/ui/cursorline.lua`), highlighting both the line and its number.
- `cmdheight = 0` so the cmdline row collapses when idle; `:`/`/` still
  bring it up, and `:messages` recalls anything that flashed by.
- `startofline = true` so line jumps (`gg`, `G`, `Ctrl-D`, etc.) land on
  the first non-blank character of the target line.
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

| Key          | Action                    |
| ------------ | ------------------------- |
| `<leader>mp` | Toggle Markdown rendering |

`blink.cmp` is disabled in markdown buffers so the completion menu doesn't
fight with the prose flow. Copilot ghost text still works, and `<Tab>` is
remapped buffer-locally in markdown to accept the suggestion (or insert a
real tab if no suggestion is visible). Markdown is formatted with `prettier`
via `conform.nvim` on save.

## Statusline

`mini.statusline` (from `mini.nvim`) — global statusline
(`laststatus = 3`, one bar across all splits) with a custom
`content.active` that trims the default to: mode, git branch + diff,
diagnostic counts (from the same `vim.diagnostic` config as the gutter),
LSP servers, filename + modified flag, search count, filetype (icon via
`nvim-web-devicons`), and a compact `line:col` location. Encoding,
fileformat, file size, and percentage-through-file are removed to keep
the bar quiet.

Paired with `cmdheight = 0` (see Editor Defaults), the statusline sits
flush against the bottom edge — no dead cmdline row beneath.

The wider `mini.nvim` package is installed as a single repo and unlocks
the rest of the family (`mini.surround`, `mini.pairs`, `mini.indentscope`,
etc.) via `require('mini.X').setup()` — no extra downloads needed when
adding more modules later.

## Sessions

`auto-session` saves on `:qa` per `cwd` and restores on entry when launched
without arguments. The previous active buffer list, splits, and cursor
positions come back; buffer-local options are _not_ saved (so global
settings like indent width always win). The tree closes before save so the
layout doesn't carry a stale tree window. Suppressed for `~/`,
`~/Downloads`, `~/Desktop`, and `/`.
