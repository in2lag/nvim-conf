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
│   │   └── keymaps.lua      Leader, clipboard, editing, smart Home
│   ├── ui/
│   │   ├── completion.lua   blink.cmp (LSP, buffer, path, snippets)
│   │   ├── format.lua       conform.nvim (prettier, eslint_d, stylua)
│   │   ├── git.lua          gitsigns + diffview (tuned theme, q-close)
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
3. Tree-sitter parsers listed in `init.lua` (`typescript`, `tsx`,
   `javascript`, `svelte`, `html`, `css`) install on first start via
   `tree-sitter-manager`.
4. Run `:Copilot auth` once to authorize GitHub Copilot.
5. The leader key is `<Space>`.

## At a Glance

| Area              | Plugin / Mechanism                       |
| ----------------- | ---------------------------------------- |
| Package manager   | `vim.pack` (built-in, Neovim 0.12+)      |
| Theme             | `gruvbox.nvim`                           |
| Fuzzy finder      | `telescope.nvim` + `plenary.nvim`        |
| File tree         | `nvim-tree.lua` + `nvim-web-devicons`    |
| Git: signs        | `gitsigns.nvim`                          |
| Git: diff view    | `diffview.nvim`                          |
| LSP               | `nvim-lspconfig` + `vtsls` (TypeScript)  |
| Tree-sitter       | `tree-sitter-manager.nvim`               |
| Completion menu   | `blink.cmp` (Lua fuzzy matcher)          |
| AI suggestions    | `copilot.lua` (ghost text)               |
| Peek / preview    | `goto-preview`                           |
| Sessions          | `auto-session` (per-cwd auto save)       |
| Formatter         | `conform.nvim`                           |
| Leader hints      | `which-key.nvim`                         |

## Completion & AI Keymaps

`blink.cmp` drives the completion menu; `copilot.lua` shows full-line ghost
text. The menu wins when both are visible (VSCode-style).

| Key                | Action                                              |
| ------------------ | --------------------------------------------------- |
| `<Tab>`            | Cycle menu if open → accept Copilot → literal tab   |
| `<S-Tab>`          | Cycle menu backwards                                |
| `<CR>`             | Accept selected menu item                           |
| `<C-n>` / `<C-p>`  | Cycle menu next / prev                              |
| `<Esc>`            | Hide menu (stay in insert; Copilot ghost text stays)|
| `<C-e>`            | Cancel menu                                         |
| `<M-l>`            | Always-on Copilot accept                            |
| `<M-Right>`        | Accept next word from Copilot                       |
| `<M-]>` / `<M-[>`  | Cycle Copilot alternatives                          |
| `<C-]>`            | Dismiss Copilot ghost text                          |

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

## Git Keymaps

| Key          | Action                                       |
| ------------ | -------------------------------------------- |
| `]c` / `[c`  | Next / previous hunk (gitsigns)              |
| `<leader>gp` | Inline preview of the current hunk           |
| `<leader>gd` | Toggle Diffview (open / close)               |
| `q` (in Diffview) | Close Diffview                          |

## Sessions

`auto-session` saves on `:qa` per `cwd` and restores on entry when launched
without arguments. The previous active buffer, splits, and cursor positions
come back. The tree closes before save so the layout doesn't carry a stale
tree window. Suppressed for `~/`, `~/Downloads`, `~/Desktop`, and `/`.
