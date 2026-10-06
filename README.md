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
│   │   ├── bufhistory.lua   Browser-style back/forward file history (H/L)
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
│   │   ├── git.lua          gitsigns + lazygit float (tuned diff theme)
│   │   ├── indent.lua       mini.indentscope (animated scope guide)
│   │   ├── markdown.lua     render-markdown.nvim (in-buffer preview)
│   │   ├── numbers.lua      Hybrid line numbers + custom statuscolumn
│   │   ├── pairs.lua        mini.pairs (auto-close brackets/quotes)
│   │   ├── peek.lua         goto-preview (peek defs/refs in a float)
│   │   ├── search.lua       Search behavior + replace shortcut
│   │   ├── session.lua      auto-session (per-cwd session restore)
│   │   ├── snacks.lua       The single Snacks.setup() (picker + notifier)
│   │   ├── smear.lua        smear-cursor.nvim (animated cursor smear)
│   │   ├── statusline.lua   mini.statusline (dim path, bold filename)
│   │   ├── surround.lua     mini.surround (sa/sd/sr text-object pairs)
│   │   ├── tabline.lua      Native tabline drawing the bufhistory ring
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
5. Install the language servers — or just start nvim and run
   `:LspInstallMissing`, which installs whichever are absent for the currently
   active Node/Go toolchain. See [LSP servers](#lsp-servers).
6. Optional, for debugging: Go needs `dlv` on `$PATH`; JS/TS needs
   Microsoft's `vscode-js-debug` installed manually so that
   `~/.local/share/nvim/js-debug/src/dapDebugServer.js` exists.
7. The leader key is `<Space>`.

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
| Fuzzy finder     | `snacks.nvim` (picker module)                           |
| Notifications    | `snacks.nvim` (notifier module, replaces `vim.notify`)  |
| File tree        | `nvim-tree.lua` + `nvim-web-devicons`                   |
| Git: signs       | `gitsigns.nvim`                                         |
| Git: full UI     | `lazygit` in a float (via `snacks.lazygit`)             |
| LSP              | `nvim-lspconfig` + `vtsls`, `gopls`, `svelte`, `angularls` |
| Debugging        | `nvim-dap` + `nvim-dap-ui`, `nvim-dap-go`, virtual text |
| Tree-sitter      | `tree-sitter-manager.nvim`                              |
| Completion menu  | `blink.cmp` (Lua fuzzy matcher)                         |
| AI suggestions   | `copilot.lua` (ghost text)                              |
| Peek / preview   | `goto-preview`                                          |
| File history     | `core/bufhistory` ring + native tabline drawn from it   |
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
| `gpr`             | Peek references (snacks picker)    |
| `gpc`             | Close all peek windows             |
| `q` (in float)    | Close this peek window             |
| `Q` (in float)    | Close all peek windows             |
| `<CR>` (in float) | Promote peek to full buffer        |

`svelte-language-server` runs on `.svelte` buffers so peek/refs work from
inside Svelte components. `vtsls` is configured with `typescript-svelte-plugin`
as a global TS server plugin, so references on a TS symbol also surface
usages from `.svelte` files. Both packages live in the global npm prefix.

Peek needs an attached server that supports the method. If none does, the
keymaps report it through the notifier naming the method, filetype and attached
clients, instead of letting `goto-preview` `print()` the failure — that reaches
you as a bare `press ENTER` prompt under `cmdheight=0`. The usual cause is a
language server missing from `$PATH`; see [LSP servers](#lsp-servers).

## LSP servers

| Server      | Executable     | Install                                                                     |
| ----------- | -------------- | --------------------------------------------------------------------------- |
| `vtsls`     | `vtsls`        | `npm i -g @vtsls/language-server typescript typescript-svelte-plugin`       |
| `svelte`    | `svelteserver` | `npm i -g svelte-language-server`                                           |
| `angularls` | `ngserver`     | `npm i -g @angular/language-server`                                         |
| `gopls`     | `gopls`        | `go install golang.org/x/tools/gopls@latest`                                |

`lua/core/lsp.lua` only calls `vim.lsp.enable()` for servers whose executable is
actually on `$PATH`. Missing ones are collected and reported in a single startup
notification naming them and the active `node`, and **`:LspInstallMissing`**
reinstalls exactly those (npm packages batched into one `npm i -g`, `gopls` via
`go install`) for the current toolchain. Restart with `:restart` afterwards.

This exists because global npm binaries are **per-Node-version**. Switching Node
— including `nvm alias default 22` silently following a newly installed 22.x —
moves the global prefix out from under every `npm i -g` language server at once.
The failure is near-silent: no client attaches, and LSP features report only
"not supported by any server", which `cmdheight=0` reduces to a `press ENTER`
prompt. `nvm install <ver> --reinstall-packages-from=<old>` avoids it when
upgrading deliberately.

For the same reason nothing here hardcodes a Node version: `vtsls`'s `tsdk` and
the `typescript-svelte-plugin` location are resolved at startup from the `node`
on `$PATH` (`lib/node_modules/<pkg>`, stat-checked) and omitted if absent,
rather than pointing at a version-pinned path that a Node bump invalidates.

## Notifications

`snacks.notifier` takes over `vim.notify`, rendering messages as floating toasts
in the bottom-right. This is load-bearing rather than cosmetic: `cmdheight = 0`
leaves no cmdline row, so every `vim.notify` — LSP errors, plugin warnings —
previously became a `press ENTER to continue` prompt whose text was never shown.

| Key           | Action                 |
| ------------- | ---------------------- |
| `<leader>nh`  | Notification history   |
| `<leader>nd`  | Dismiss all toasts     |

History keeps everything, including toasts that timed out unseen. Note that
messages written with `print()` or `:echo` still bypass `vim.notify` and can
produce the prompt; `lua/ui/peek.lua` works around one such case in
`goto-preview`.

`Snacks.setup()` may only be called **once** — a second call errors with
"snacks.nvim is already setup" and drops that config. All snacks modules are
therefore configured in `lua/ui/snacks.lua`, which `init.lua` requires before
any module that uses the `Snacks` global; feature modules only consume it.

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

**Display is debounced while typing.** Any edit hides the buffer's diagnostics
entirely — signs, underline and virtual text — and they come back once you stop
typing for `DEBOUNCE_MS` (500 ms, at the top of `lua/ui/diagnostics.lua`).
Leaving insert mode shows them immediately rather than waiting out the delay,
since you have clearly stopped typing.

`vim.diagnostic` has no delay or debounce option, so this is done by hand with
`vim.diagnostic.enable(false, { bufnr })` on `TextChanged`/`TextChangedI`/
`TextChangedP` plus a deferred re-enable. A per-buffer generation counter, rather
than a timer handle, decides whether a pending re-enable is still current: each
edit bumps the count and thereby invalidates the previous callback, so there are
no timers to stop, close or leak on buffer wipeout.

`update_in_insert` stays **true** on purpose. It controls whether diagnostics are
*recomputed* in insert mode, while the debounce controls whether they are
*displayed* — flipping it off would mean whatever reappears after your pause is
stale. (Neovim's own default is `false`, which instead freezes stale diagnostics
on screen while you type and refreshes them on `InsertLeave`.)

Document highlight: when the cursor rests on a symbol for `updatetime`
(100 ms), all other references of that symbol in the buffer get a subtle
highlight (`vim.lsp.buf.document_highlight`), cleared on cursor move.
Enabled per buffer on `LspAttach` for servers that support it.

| Key          | Action                                  |
| ------------ | --------------------------------------- |
| `]d` / `[d`  | Next / prev diagnostic (Neovim default) |
| `<C-W>d`     | Open diagnostic float (Neovim default)  |
| `<leader>cd` | Open diagnostic float at cursor         |
| `<leader>cq` | Project diagnostics in snacks picker    |

## Editing Keymaps

| Key                       | Action                                             |
| ------------------------- | -------------------------------------------------- |
| `<leader>D`               | Duplicate line / selection                         |
| `<leader>o` / `<leader>O` | Insert blank line(s) below / above (takes a count) |
| `<leader>y`               | Yank to system clipboard                           |
| `<leader>v`               | Paste from system clipboard                        |
| `<leader>P`               | Paste over selection without losing yank           |
| `<leader>x`               | Black-hole delete (no clobber of yank)             |
| `H` / `L`                 | Back / forward through main-window file history    |
| `<D-s>` (Cmd+S)           | Save file and return to normal mode                |

`<D-s>` is Cmd+S: Ghostty forwards `Cmd+S` to nvim as `<D-s>` over the kitty
keyboard protocol. It is mapped in normal, insert and visual modes as
`<Esc><cmd>write<CR>`, so saving from insert or visual always lands you in
normal mode — no separate `<Esc>` afterwards. `conform`'s `format_on_save` is
synchronous, so leaving insert first also keeps formatting from fighting the
cursor. As with any `<Esc>`, exiting insert moves the cursor one column left;
normal mode cannot hold a position past the last character. Defined in
`lua/core/keymaps.lua`.

`H` and `L` walk the files the **main editing windows** have held, back and
forward. Defined in `lua/core/bufhistory.lua`.

They used to be `:bprevious`/`:bnext`, which is what made them feel random:
those walk buffer *number* order — the order buffers were created — which has
nothing to do with the order you visited files. The buffer list fills up from
things that do not feel like opening a buffer: the snacks pickers
(`<leader><leader>`, `<leader>p`, `<leader>gs`), the references picker behind
`gpr`, the `<CR>` promote hook in `lua/ui/peek.lua`, and `auto-session`
restoring a whole session's list at startup. So `H` reliably went somewhere,
just never where you had been.

Recording is deliberately narrow: only real files (`buftype == ""`) in
non-floating windows. Peek windows, pickers, `lazygit`, `nvim-tree`, terminals
and quickfix are all skipped, so navigating a picker never pollutes the history
you use the picker to navigate. Inside `nvim-tree` its own buffer-local `H`/`L`
(toggle dotfiles / group-empty) still win, since these are global mappings.

Visiting a new file truncates the forward branch, like a browser, but the ends
wrap: `H` from the oldest file lands on the newest and `L` from the newest lands
on the oldest, so neither key ever dead-ends. The walk is bounded to one lap, so
a history whose only live entry is the file you are already in reports "no other
file" instead of spinning. Buffers deleted since they were recorded are skipped
rather than jumped to, and closing a file's window with `:q` forgets it, so a
file you deliberately closed stops coming back around the ring. That last one
hooks `QuitPre` rather than `WinClosed` on purpose: `WinClosed` also fires when a
peek float is dismissed, and `goto-preview` resolves its target through
`vim.uri_to_bufnr`, which returns the *listed* buffer number when the file is
already open — so dismissing a peek would silently evict that file from the
history. A `:q` on a window whose file is still open in another window leaves the
history alone. The buffer itself stays listed either way (that is what `:q` does
with `hidden` set), so it remains available in `<leader>fb`; use `:bd` if you
want it gone from the buffer list too.

The stack holds 100 entries. The tabline across the top draws it live (see
[Tabline](#tabline)); `:BufHistory` prints the raw stack with `>` marking where
you are, dead entries included, when the bar is not enough to explain a jump.

Worth knowing what this is *not*: it is per-history, not per-window, so splits
share one stack. For the two adjacent native motions, `<C-^>` still toggles the
alternate file and `<C-o>`/`<C-i>` walk the jumplist by cursor position rather
than by file.

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
`markdown`, and `terminal` buffers via a buffer-local
`miniindentscope_disable` flag.

## Cursor (`smear-cursor.nvim`)

The cursor smears toward its target in real time (Neovide-style), making
jumps easy to follow. Configured in `lua/ui/smear.lua`. `smear_insert_mode`
is off so typing stays crisp — the smear only fires on navigation moves.
Feel is tuned via `stiffness` / `trailing_stiffness` (lower = longer smear)
and `damping`; `:SmearCursorToggle` turns it on/off live. If the smear
glyphs look blocky, set `legacy_computing_symbols_support = true` (needs a
font with octant/legacy-computing symbols).

## Find / Search Keymaps (snacks picker)

| Key                       | Action                                       |
| ------------------------- | -------------------------------------------- |
| `<leader><leader>`        | Smart find files (frecency-sorted)           |
| `<leader>p`               | Live grep the project                        |
| `<leader>fb`              | Find buffers                                 |
| `<leader>sw` (normal)     | Grep word under cursor (project-wide)        |
| `<leader>sw` (visual)     | Grep the current selection (project-wide)    |
| `<leader>sr`              | Search & replace word under cursor (in file) |
| `dd` in buffers picker    | Delete the highlighted buffer                |

`<leader><leader>` uses the snacks `smart` source: open buffers, recent
files, and project files merged, deduplicated, and ranked by frecency
with a bonus for the current working directory. Recently visited files
from other projects may appear in the list (ranked low); add
`smart = { filter = { cwd = true } }` to the picker sources to keep it
project-local.

The files and grep pickers include hidden files; `.git/` is excluded.
`.gitignore` is honored via ripgrep's defaults. Image files (`png`,
`jpg`, `gif`, `svg`, `webp`, `ico`, …) are excluded from the files and
grep sources in the snacks picker config (`lua/ui/snacks.lua`).

## File Tree

`nvim-tree` opens on the left at 50 columns. The `.git/` directory is
filtered out of the listing.

| Key         | Action                                              |
| ----------- | --------------------------------------------------- |
| `<leader>e` | Open tree → focus tree → jump back to code (toggle) |
| `<leader>E` | Toggle tree sidebar (keeps cursor where it is)      |

## Git Keymaps

| Key                        | Action                              |
| -------------------------- | ----------------------------------- |
| `]c` / `[c`                | Next / previous hunk (gitsigns)     |
| `<leader>gp`               | Inline preview of the current hunk  |
| `<leader>gs`               | Changed files in a snacks picker    |
| `<leader>gh`               | All changed hunks in a snacks picker |
| `<leader>go`               | Open the PR that introduced the current line |
| `<leader>gt`               | Toggle inline line blame            |
| `<leader>gd`               | Open `lazygit` in a float           |

`<leader>gd` opens `lazygit` in a floating terminal via `Snacks.lazygit`, which
covers staging (by file, hunk or line), commits, amends, branches, rebases,
stashes and log browsing. It needs the `lazygit` binary on `$PATH`; `snacks`
itself needs no setup entry for this, as the module is on-demand.

Two things `snacks` wires up beyond launching it. It generates a lazygit theme
from the current colorscheme's highlight groups (`MatchParen`, `FloatBorder`,
`Visual`, `DiagnosticError`, ...) into `stdpath('cache')/lazygit-theme.yml` and
injects it by appending to `LG_CONFIG_FILE`, so your own `config.yml` is layered
first and preserved; it is regenerated on `ColorScheme`. And it sets
`os.editPreset = "nvim-remote"`, so pressing `e` on a file inside lazygit closes
lazygit and opens that file in a tab of the **running** nvim instead of nesting a
second one -- this works via the `$NVIM` variable nvim exports inside terminal
buffers, so no `nvr` is required. Because snacks' generated config is layered
last, its `editPreset` and `nerdFontsVersion` win over your own `config.yml`.

This replaced `diffview.nvim`, which previously held `<leader>gd`. The tradeoff:
lazygit does far more git *operations*, but its diff pane is plain terminal text
rather than real editor buffers, so there is no treesitter highlighting or
`]c`/`[c` navigation inside it, and no file-history browsing across commits. For
reading changes, `<leader>gh` (hunks picker) and `<leader>gp` (inline preview)
cover the common cases. `Snacks.lazygit.log_file()` gives the current file's
history if you want it bound.

`<leader>go` answers "why is this line here?" by landing on the pull request
that introduced it. It blames the line for its commit, then asks GitHub's
"pull requests associated with a commit" endpoint (`gh api
repos/{owner}/{repo}/commits/<sha>/pulls`) which PR that commit came from. That
endpoint matches the *merge result*, so squash, merge and rebase commits all
resolve rather than only branch heads. If nothing is associated -- a commit
pushed straight to a branch, or a rebase that rewrote the sha the PR carried --
it retries with `gh pr list --search <sha>`, and failing that opens the commit
page instead of erroring, which is what happens in this repo (no PRs, all
direct-to-main).

Two details worth knowing. The blame runs against the **buffer** rather than the
file on disk (`git blame --contents -`, buffer piped in on stdin): with unsaved
edits above the cursor the two disagree about which line is which, and you would
silently open the PR for a neighbouring line. And both `git` and `gh` run from
the file's own directory, because the `{owner}/{repo}` placeholders resolve from
the remote found there -- not necessarily nvim's cwd once `auto-session` or a
picker has moved it. Requires `gh` on `$PATH` and authenticated (`gh auth
login`); the whole chain is async via `vim.system`, so the network call never
blocks the editor.

This replaced `Snacks.gitbrowse()`, which previously held `<leader>go` and opened
the file itself on the remote at the current line. Consequence: there is no
longer a mapping for a plain file permalink, and `<leader>go` on an uncommitted
line warns instead of linking it.

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
- `scrollopt = "ver,jump"` so `:diffthis` windows stay synced vertically.
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

`mini.statusline` (from `mini.nvim`) with a custom `content.active` that trims
the default to: mode, diagnostic counts (from the same `vim.diagnostic` config
as the gutter), LSP servers, the filename, search count, filetype (icon via
`nvim-web-devicons`), and a compact `line:col` location. Encoding, fileformat,
file size, and percentage-through-file are removed to keep the bar quiet. One
bar per window (`laststatus = 2`, set by `mini.statusline` itself).

Git branch and diff summary are deliberately absent — they crowded out the
filename, which is the thing worth reading. `gitsigns` still shows per-line
state in the gutter, and `titlestring` carries the cwd (worktree) name.

**Filename rendering.** The path is always cwd-relative, with the directories
dimmed (`StatuslineFileDir`) and the basename bold and brighter
(`StatuslineFileTail`), so your eye lands on the file you are in:

```
 Normal  󰰎 ++  packages/logger/src/index.ts        typescript   1:1
                └──── dimmed ────┘└─ bold ─┘
```

Below 100 columns it collapses to the basename alone (`index.ts`).

This replaces `mini.statusline`'s `section_filename`, which switches to `%F` —
the **absolute** path — once the window reaches `trunc_width`, so a wider window
produced a *longer* path (75+ characters in a nested worktree), buried the
basename at the far right, and repeated the branch name. Two implementation
details matter if you edit it: `combine_groups` pads every group with a space on
each side, so the two halves of the path cannot be separate groups without a gap
appearing mid-path — `filename_section` returns one string carrying its own
`%#hl#` switches, and doubles any literal `%`. The two highlight groups are
derived from `Comment` and `Normal` and rebuilt on `ColorScheme`, because
`init.lua` applies the colorscheme *after* this module loads.

Paired with `cmdheight = 0` (see Editor Defaults), the statusline sits
flush against the bottom edge — no dead cmdline row beneath.

The wider `mini.nvim` package is installed as a single repo and unlocks
the rest of the family (`mini.surround`, `mini.pairs`, `mini.indentscope`,
etc.) via `require('mini.X').setup()` — no extra downloads needed when
adding more modules later.

## Tabline

A single bar across the top that draws the `H`/`L` file history from
`lua/core/bufhistory.lua`, oldest on the left, newest on the right, the entry
you are sitting on highlighted. No plugin: `'tabline'` is a statusline-style
format string, and `lua/ui/tabline.lua` builds one from the history array.
`showtabline = 2` keeps it up even with one file open.

```
   init.lua   󰂺 README.md  [  tabline.lua ]   bufhistory.lua ●   keymaps.lua
                            └── current ──┘                  └ modified
```

Because it is the same list the keys walk, the bar is the keys made visible: `H`
slides the highlight one entry left, `L` one entry right, a new visit appends on
the right and drops every entry that was to the right of you (the browser
forward-branch rule), and a buffer wiped since it was recorded is simply not
drawn. Left-click an entry to jump to it, middle-click to `:bdelete` it. A
modified buffer shows a warn-coloured `●` in the slot that is otherwise padding,
so saving does not shift the entries beside it.

Basenames only, except where two entries would read the same, in which case each
gets its parent directory (`logger/index.ts`, `api/index.ts`). When the bar is
wider than the window it keeps the current entry visible and grows outwards from
it alternating sides, marking a cut edge with `‹` or `›`. Tab pages are not part
of this workflow; if one is open anyway a `tab 2/3` counter appears at the far
right so the bar does not silently lie about it.

Colours come from the theme's `TabLine`, `TabLineSel` and `TabLineFill` groups,
which catppuccin already styles; `TabLineSel` is `Normal` fg on `Normal` bg, so
the current entry reads as attached to the buffer beneath it. Only the modified
marker needs two groups of its own, derived from `DiagnosticWarn` and rebuilt on
`ColorScheme` since `init.lua` applies the colorscheme after this module loads.

`mini.tabline` would have been two lines, but it lists buffers in *number* order,
the exact ordering `H`/`L` were moved away from, and it cannot be given another
one. The history module exposes `state()` and `jump_to(i)` for this bar and
requests a `redrawtabline` when it mutates outside an event that would redraw
anyway (`forget()` from `QuitPre`/`BufDelete`).

---

## Sessions

`auto-session` saves on `:qa` per `cwd` and restores on entry when launched
without arguments. The previous active buffer list, splits, and cursor
positions come back; buffer-local options are _not_ saved (so global
settings like indent width always win). The tree closes before save so the
layout doesn't carry a stale tree window. Suppressed for `~/`,
`~/Downloads`, `~/Desktop`, and `/`.
