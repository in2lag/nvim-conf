# Neovim Configuration

Personal Neovim setup. Built on Neovim 0.12+ using the built-in `vim.pack`
package manager (no `lazy.nvim`, no `packer`). Modular Lua under `lua/core`
and `lua/ui`.

## Layout

```
.
├── init.lua                 Entry point: plugin list, LSP, completion, theme
├── nvim-pack-lock.json      vim.pack lockfile (pinned plugin revisions)
├── lua/
│   ├── core/
│   │   └── keymaps.lua      Leader, clipboard, editing, smart Home
│   └── ui/
│       ├── git.lua          gitsigns + diffview
│       ├── numbers.lua      Hybrid line numbers + custom statuscolumn
│       ├── search.lua       Search behavior + replace shortcut
│       └── tree.lua         nvim-tree with smart toggle
└── docs/
    ├── keymaps.md           Full keybinding reference
    ├── plugins.md           Plugin catalog
    ├── modules.md           Per-module deep dive
    ├── completion.md        Autocompletion behavior
    └── lsp.md               LSP configuration
```

## Quick Start

1. Clone into `~/.config/nvim`.
2. Launch `nvim`. `vim.pack` resolves plugins from `nvim-pack-lock.json` on
   first run and clones them into the pack directory.
3. Tree-sitter parsers listed in `init.lua` (`typescript`, `tsx`,
   `javascript`, `svelte`, `html`, `css`) install on first start via
   `tree-sitter-manager`.
4. The leader key is `<Space>`.

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
| Completion        | Built-in `vim.opt.autocomplete` (no cmp) |

## Documentation

- [Keymaps](docs/keymaps.md) — every binding, grouped by purpose
- [Plugins](docs/plugins.md) — what each plugin does and where it's configured
- [Modules](docs/modules.md) — file-by-file walkthrough of `lua/`
- [Completion](docs/completion.md) — built-in autocomplete behavior
- [LSP](docs/lsp.md) — language server setup
