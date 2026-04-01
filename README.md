# Neovim DevOps IDE

A full-featured Neovim configuration designed as a modern IDE — with a focus on **DevOps workflows**: Terraform, Kubernetes, Ansible, Docker, Helm, Go, Python, Bash, and more.

> **Requires Neovim ≥ 0.11** — the LSP configuration uses the native `vim.lsp.config` / `vim.lsp.enable` API introduced in 0.11.

---

## Table of Contents

1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation) — [Quick Install](#quick-install-recommended) · [Manual](#manual-installation)
4. [Configuration Structure](#configuration-structure)
5. [Plugin Overview](#plugin-overview)
6. [Keybinding Reference](#keybinding-reference)
7. [DevOps Language Support](#devops-language-support)
8. [AI Assistant (Ollama)](#ai-assistant-ollama)
9. [Tips & Tricks](#tips--tricks)
10. [Customisation](#customisation)

---

## Features

| Category | Details |
|---|---|
| **Plugin Manager** | [lazy.nvim](https://github.com/folke/lazy.nvim) — fast, lazy-loaded |
| **Colorscheme** | [Tokyo Night](https://github.com/folke/tokyonight.nvim) (night style) — easy on the eyes |
| **LSP** | Mason auto-installer + 11 pre-configured language servers (Neovim 0.11 native API) |
| **Completion** | nvim-cmp with LSP, snippets, paths, buffer words |
| **Snippets** | LuaSnip + friendly-snippets (VS Code compatible) |
| **Syntax** | Treesitter with 30+ parsers including Terraform, Dockerfile, YAML |
| **Fuzzy Find** | Telescope with FZF native sorter |
| **File Explorer** | Neo-tree with Git status icons |
| **Git** | Gitsigns (gutter) + Neogit (TUI) + Diffview (diffs/history) |
| **Terminal** | ToggleTerm with named terminals: LazyGit, K9s, Python REPL, Htop |
| **Database UI** | nvim-dbee for browsing databases and running queries inside Neovim |
| **Formatting** | conform.nvim auto-format on save |
| **Linting** | nvim-lint (shellcheck, hadolint, tflint, yamllint, flake8, ansiblelint) |
| **Folding** | nvim-ufo with LSP/Treesitter providers |
| **Navigation** | Flash.nvim (`s` = jump anywhere, `S` = treesitter select), vim-illuminate (word highlights) |
| **UI** | Noice (cmdline/messages), lualine, bufferline, which-key, alpha dashboard |
| **DevOps extras** | Ansible filetype detection + Jinja2 syntax, Python venv picker, DAP debugger (Python) |
| **AI assistant** | [CodeCompanion](https://github.com/olimorris/codecompanion.nvim) + [Ollama](https://ollama.com) — fully local, no data leaves your machine |

---

## Prerequisites

### Required

| Tool | How to Install |
|---|---|
| **Neovim ≥ 0.11** | `brew install neovim` (macOS) or see [neovim.io](https://neovim.io) |
| **git** | pre-installed on most systems |
| **make** | `xcode-select --install` (macOS) or `apt install build-essential` |
| **ripgrep** | `brew install ripgrep` — powers live grep in Telescope (optional; telescope degrades gracefully without it) |
| **fd** | `brew install fd` — faster `find` for Telescope file search (optional; falls back to `rg` or system `find`) |
| **A Nerd Font** | Install any [Nerd Font](https://www.nerdfonts.com) and set it in your terminal |
| **Node.js ≥ 18** | `brew install node` — required by several LSP servers |
| **Python 3** | `brew install python` — for pyright, black, flake8, ansible |
| **Go** | `brew install go` — for gopls |

### For DevOps tools (install as needed)

```bash
brew install terraform       # terraformls
brew install ansible         # ansiblels + ansiblelint
brew install helm            # helm-ls
brew install kubectl         # K9s dependency
brew install k9s             # Kubernetes TUI in terminal
brew install lazygit         # Git TUI
brew install hadolint        # Dockerfile linter
brew install tflint          # Terraform linter
pip3 install black isort flake8 ansiblelint yamllint
```

---

## Installation

### Quick Install (recommended)

Clone the repo and run the install script — it handles everything:

```bash
git clone https://github.com/your-username/neovim-setup.git ~/neovim-setup
cd ~/neovim-setup
./install.sh
```

The script will:
- Install **Neovim** (via Homebrew on macOS or apt/dnf/pacman on Linux)
- Install core dependencies: git, make, ripgrep, fd, Node.js, Python 3
- **Back up** any existing `~/.config/nvim`, `~/.local/share/nvim`, `~/.local/state/nvim`, and `~/.cache/nvim` with a timestamp suffix (e.g. `.bak.20260317_142500`)
- Copy the config to `~/.config/nvim`
- Offer to install optional DevOps CLI tools (Terraform, Ansible, Helm, kubectl, k9s, lazygit, etc.)
- Offer to install **Ollama** and pull the `codestral` model for local AI assistance

**Symlink mode** — keep the config living inside the cloned repo so any edits are version-controlled:

```bash
./install.sh --symlink
```

> Run `./install.sh --help` to see all options.

---

### Manual Installation

#### Step 1 — Back up your existing config (if any)

```bash
STAMP=$(date +%Y%m%d_%H%M%S)
mv ~/.config/nvim        ~/.config/nvim.bak.$STAMP        2>/dev/null || true
mv ~/.local/share/nvim   ~/.local/share/nvim.bak.$STAMP   2>/dev/null || true
mv ~/.local/state/nvim   ~/.local/state/nvim.bak.$STAMP   2>/dev/null || true
mv ~/.cache/nvim         ~/.cache/nvim.bak.$STAMP         2>/dev/null || true
```

#### Step 2 — Copy this config to your Neovim directory

**Option A: Copy directly**
```bash
cp -r "/path/to/neovim-setup/nvim" ~/.config/nvim
```

**Option B: Symlink (edits go directly to this repo)**
```bash
ln -s "/path/to/neovim-setup/nvim" ~/.config/nvim
```

#### Step 3 — Open Neovim

```bash
nvim
```

On first launch:
1. **lazy.nvim** bootstraps itself automatically
2. All plugins download and install (takes ~1–2 minutes)
3. **Mason** auto-installs all LSP servers, linters, and formatters
4. **Treesitter** downloads all language parsers

> You can watch plugin install progress with `:Lazy` and LSP install progress with `:Mason`.

#### Step 4 — Verify installation

```vim
:checkhealth          " Check for any missing dependencies
:Mason                " Verify all tools are installed
:Lazy                 " View plugin status
:TSInstallInfo        " Check Treesitter parsers
```

---

## Configuration Structure

```
nvim/
├── init.lua                    ← Entry point: loads core + bootstraps lazy.nvim
└── lua/
    ├── core/
    │   ├── options.lua         ← Vim options (tabs, search, UI, folds…)
    │   ├── keymaps.lua         ← Global keymaps (non-plugin)
    │   └── autocmds.lua        ← Autocommands (yank highlight, filetypes…)
    └── plugins/
        ├── colorscheme.lua     ← Tokyo Night theme
        ├── ui.lua              ← Noice, notify, dashboard, indent guides, which-key
        ├── statusline.lua      ← Lualine + Bufferline + buffer management
        ├── explorer.lua        ← Neo-tree file explorer
        ├── telescope.lua       ← Fuzzy finder
        ├── treesitter.lua      ← Syntax highlighting + text objects
        ├── lsp.lua             ← Mason + LSP servers + diagnostics
        ├── completion.lua      ← nvim-cmp + LuaSnip
        ├── git.lua             ← Gitsigns + Neogit + Diffview
        ├── terminal.lua        ← ToggleTerm + named terminals
        ├── editor.lua          ← Autopairs, comments, surround, formatting, linting…
        └── devops.lua          ← Ansible syntax, Jinja2, Python venv selector, DAP debugger        └── ai.lua              ← CodeCompanion + Ollama (local AI assistant)```

---

```

## Plugin Overview

| Plugin | Purpose |
|---|---|
| `lazy.nvim` | Plugin manager with lazy-loading |
| `tokyonight.nvim` | Colorscheme (Tokyo Night — night style) |
| `noice.nvim` | Better cmdline, messages, popupmenu |
| `nvim-notify` | Notification system |
| `alpha-nvim` | Start screen / dashboard |
| `lualine.nvim` | Status line |
| `bufferline.nvim` | Buffer tabs at top |
| `which-key.nvim` | Keybinding popup hints |
| `indent-blankline` | Indent guide lines |
| `mini.indentscope` | Active scope highlight |
| `neo-tree.nvim` | File explorer with Git status |
| `telescope.nvim` | Fuzzy finder (files, grep, buffers…) |
| `nvim-treesitter` | Syntax highlighting + text objects |
| `nvim-treesitter-context` | Shows current function/class at top |
| `nvim-lspconfig` | LSP configuration |
| `mason.nvim` | Auto-install LSP servers & tools |
| `nvim-cmp` | Completion engine |
| `LuaSnip` | Snippet engine + VS Code snippets |
| `conform.nvim` | Auto-format on save |
| `nvim-lint` | Async linting |
| `nvim-ufo` | Better code folding |
| `gitsigns.nvim` | Git signs in gutter + hunk operations |
| `neogit` | Full Git TUI (like Magit) |
| `diffview.nvim` | Side-by-side diffs / file history |
| `toggleterm.nvim` | Integrated terminal (float/split/tab) |
| `flash.nvim` | Fast cursor jumps (s/S) |
| `vim-illuminate` | Highlight all occurrences of word |
| `nvim-autopairs` | Auto-close brackets/quotes |
| `Comment.nvim` | Toggle line/block comments |
| `nvim-surround` | Add/change/delete surrounding chars |
| `nvim-spectre` | Project-wide search & replace |
| `todo-comments.nvim` | Highlight TODO/FIXME/NOTE |
| `persistence.nvim` | Auto-save/restore sessions |
| `trouble.nvim` | Diagnostics list panel |
| `fidget.nvim` | LSP progress spinner |
| `nvim-bqf` | Better quickfix list |
| `ansible-vim` | Ansible filetype detection (`yaml.ansible`) + improved syntax |
| `Vim-Jinja2-Syntax` | Jinja2 / J2 template syntax highlighting |
| `venv-selector.nvim` | Python virtual environment picker (Telescope) |
| `nvim-dbee` | Visual database browser and query runner inside Neovim |
| `nvim-dap` | Debug Adapter Protocol core |
| `nvim-dap-ui` | Debug UI (variables, call stack, breakpoints, REPL) |
| `nvim-dap-python` | Python debug adapter (uses Mason-installed debugpy) |
| `nvim-dap-virtual-text` | Inline variable values during debug sessions |
| `codecompanion.nvim` | AI chat + inline actions powered by Ollama |
| `render-markdown.nvim` | Renders markdown + code blocks in the AI chat buffer |

---

## Keybinding Reference

> **Leader key** = `<Space>`

### Navigation & Windows

| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Move between splits |
| `<C-Arrow>` | Resize current split |
| `<leader>sv` | Split vertically |
| `<leader>sh` | Split horizontally |
| `<leader>se` | Equalize splits |
| `<leader>sx` | Close current split |
| `<S-h>` | Prev buffer |
| `<S-l>` | Next buffer |
| `<C-d>` | Scroll down (cursor stays centred) |
| `<C-u>` | Scroll up (cursor stays centred) |
| `<C-a>` | Select all |

### File & Buffer Management

| Key | Action |
|---|---|
| `<leader>e` | Toggle file explorer (Neo-tree) |
| `<leader>E` | Explorer at current file's directory |
| `<leader>bd` | Delete current buffer (smart) |
| `<leader>bD` | Force-delete buffer |
| `<leader>bp` | Pin buffer |
| `<leader>bo` | Close other buffers |
| `<leader>ba` | Close all buffers |
| `<C-s>` | Save file (normal + insert) |

### Find / Telescope

| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fr` | Recent files |
| `<leader>fg` | Live grep |
| `<leader>fw` | Grep word under cursor |
| `<leader>fb` | Find open buffers |
| `<leader>fh` | Help tags |
| `<leader>fk` | Browse keymaps |
| `<leader>fd` | Buffer diagnostics |
| `<leader>fD` | Workspace diagnostics |
| `<leader>fs` | Document symbols |
| `<leader>fS` | Workspace symbols |
| `<leader>fG` | Git commits |
| `<leader>fB` | Git branches |
| `<leader>ft` | Find TODO comments |
| `<leader>f/` | Fuzzy search current buffer |

*Inside Telescope: `<C-j/k>` move up/down, `<C-q>` send to quickfix, `<Esc>` close.*

### LSP

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | References (Telescope) |
| `gi` | Go to implementation |
| `gt` | Type definition |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>cf` | Format buffer / selection |
| `<leader>cl` | Run codelens |
| `[d` / `]d` | Prev / next diagnostic |
| `<leader>dl` | Show diagnostic float |
| `<leader>dq` | Diagnostics to location list |
| `<leader>xx` | Toggle Trouble (workspace diagnostics) |
| `<leader>xX` | Toggle Trouble (buffer diagnostics) |
| `<leader>cs` | Symbols panel (Trouble) |

### Git

| Key | Action |
|---|---|
| `<leader>gg` | Neogit status (git TUI) |
| `<leader>gG` | LazyGit (floating terminal) |
| `<leader>gc` | Git commit |
| `<leader>gp` | Git pull |
| `<leader>gP` | Git push |
| `<leader>gb` | Git branches |
| `<leader>gl` | Git log |
| `<leader>gf` | File history (current file) |
| `<leader>gd` | Diff view |
| `]h` / `[h` | Next / prev hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghS` | Stage entire buffer |
| `<leader>ghb` | Blame line |
| `<leader>ghB` | Blame buffer |
| `<leader>ghd` | Diff this file |
| `<leader>gtb` | Toggle inline git blame |
| `ih` (visual/operator) | Select hunk text object |

### Terminal

| Key | Action |
|---|---|
| `<C-\>` | Toggle terminal (float) |
| `<leader>tf` | Float terminal |
| `<leader>th` | Horizontal terminal |
| `<leader>tv` | Vertical terminal |
| `<leader>tt` | Tab terminal |
| `<leader>gG` | LazyGit |
| `<leader>K` | K9s (Kubernetes) |
| `<leader>tp` | Python REPL |
| `<leader>tm` | Htop |
| `<leader>tT` | Terraform console |
| `<Esc><Esc>` | Exit terminal mode |

### Flash Navigation

> **Note:** `s` and `S` are remapped from their Vim defaults (`s` = substitute char, `S` = substitute line) to flash.nvim. Use `cl` (change letter) and `cc` (change line) as direct replacements.

| Key | Mode | Action |
|---|---|---|
| `s` | n/x/o | Type 2 chars → jump to any match on screen |
| `S` | n/x/o | Jump to a treesitter syntax node |
| `r` | o | Remote flash — apply operator at a distant location without moving cursor |
| `R` | o/x | Treesitter-aware remote search |
| `<C-s>` | c | Toggle flash inside `/` search |

**Example:** `d s fu <label>` deletes from cursor to any visible `fu…` match in one motion.

### Editing

| Key | Action |
|---|---|
| `gcc` | Toggle comment (line) |
| `gc` (visual) | Toggle comment (selection) |
| `<A-j/k>` | Move line / selection up or down |
| `<` / `>` (visual) | Indent left/right (stays selected) |
| `p` (visual) | Paste without overwriting register |
| `ys{motion}{char}` | Surround with character |
| `cs{old}{new}` | Change surrounding character |
| `ds{char}` | Delete surrounding character |
| `]]` / `[[` | Next / prev reference (vim-illuminate) |
| `<C-space>` | Expand treesitter selection |
| `<BS>` | Shrink treesitter selection |

### Debugging (DAP)

| Key | Action |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue / start debug session |
| `<leader>di` | Step into |
| `<leader>dn` | Step over |
| `<leader>do` | Step out |
| `<leader>dx` | Terminate session |
| `<leader>dr` | Toggle REPL |
| `<leader>dl` | Run last debug config |
| `<leader>dL` | Set log point |
| `<leader>du` | Toggle DAP UI panels |
| `<leader>de` | Evaluate expression (n/v) |
| `<leader>dpm` | Python: run test method under cursor |
| `<leader>dpc` | Python: run test class under cursor |
| `<leader>dps` | Python: debug visual selection |

### Python

| Key | Action |
|---|---|
| `<leader>pv` | Open venv selector (Telescope) |
| `<leader>pV` | Re-use last selected venv |

### Database

| Key / Command | Action |
|---|---|
| `<leader>od` | Open DBee database UI |
| `:Dbee` | Open DBee manually |

### AI Assistant

| Key | Mode | Action |
|---|---|---|
| `<leader>ac` | n/v | Toggle AI chat panel |
| `<leader>an` | n/v | New AI chat |
| `<leader>ai` | n/v | Inline prompt (edit/generate at cursor) |
| `<leader>aa` | n/v | Action picker (all available AI actions) |
| `<leader>ae` | v | Explain selected code |
| `<leader>af` | v | Fix selected code |
| `<leader>at` | v | Generate tests for selection |
| `<leader>ar` | v | Code review for selection |
| `<leader>am` | n | Generate a git commit message |

*Inside the chat buffer: `<CR>` send, `<C-c>` stop, `q` close, `]c`/`[c` next/prev chat.*

### Code Folding

| Key | Action |
|---|---|
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zr` | Open one fold level |
| `zm` | Close one fold level |
| `zp` | Peek fold contents |
| `zo` / `zc` | Open / close fold under cursor |

### Treesitter Text Objects

| Motion | Action |
|---|---|
| `af` / `if` | Outer / inner function |
| `ac` / `ic` | Outer / inner class |
| `aa` / `ia` | Outer / inner argument |
| `ab` / `ib` | Outer / inner block |
| `al` / `il` | Outer / inner loop |
| `]f` / `[f` | Next / prev function start |
| `]c` / `[c` | Next / prev class start |

### Search & Replace

| Key | Action |
|---|---|
| `<leader>sr` | Open Spectre (project search & replace) |
| `<leader>sw` | Search word under cursor in Spectre |
| `<leader>sf` | Search in current file |
| `<leader>nh` | Clear search highlights |

### Sessions

| Key | Action |
|---|---|
| `<leader>qs` | Restore session for current directory |
| `<leader>ql` | Restore last session |
| `<leader>qd` | Stop auto-saving session |

### UI Toggles

| Key | Action |
|---|---|
| `<leader>uw` | Toggle word wrap |
| `<leader>us` | Toggle spell check |
| `<leader>un` | Toggle relative line numbers |
| `<leader>uc` | Toggle cursor line |
| `<leader>ut` | Toggle Treesitter context |

---

## DevOps Language Support

### Language Servers (auto-installed by Mason)

| Language / Tool | Server | Notes |
|---|---|---|
| **Bash / Shell** | `bashls` | Supports `.sh`, `.bash`, `.zsh` |
| **Python** | `pyright` | Type checking, imports, stubs |
| **Go** | `gopls` | Full support: hints, codelens, struct alignment |
| **Terraform / HCL** | `terraformls` | Format, validate, complete resource types |
| **YAML** | `yamlls` | Schema validation for K8s, GitHub Actions, Ansible, Docker Compose |
| **JSON** | `jsonls` | Schema validation for common files |
| **Dockerfile** | `dockerls` | Instruction completion + linting |
| **Docker Compose** | `docker_compose_language_service` | Service/volume/network completion |
| **Ansible** | `ansiblels` | Playbook/role/task completion; activates on `yaml.ansible` filetype |
| **Helm** | `helm_ls` | Template completion with K8s schemas |
| **Lua** | `lua_ls` | Full Neovim API completion |

### Formatters (auto-installed by Mason)

| Language | Formatter |
|---|---|
| Lua | `stylua` |
| Python | `black` + `isort` |
| Go | `goimports` + `gofmt` |
| Shell | `shfmt` (2-space indent) |
| Terraform | `terraform fmt` |
| JSON, YAML, Markdown | `prettier` |
| JS, TS, HTML, CSS | `prettier` |

### Linters (auto-installed by Mason)

| Language | Linter |
|---|---|
| Bash / Shell | `shellcheck` |
| Dockerfile | `hadolint` |
| Terraform | `tflint` |
| YAML | `yamllint` |
| Python | `flake8` |
| Ansible playbooks | `ansiblelint` |

### Debug Adapters (auto-installed by Mason)

| Language | Adapter | Notes |
|---|---|---|
| **Python** | `debugpy` | Used by `nvim-dap-python`; set breakpoints with `<leader>db` |

### YAML Schema Auto-detection

The `yamlls` server automatically applies the right schema based on filename:

| Schema | File pattern |
|---|---|
| Kubernetes | `*.yaml`, `*.yml` |
| GitHub Actions | `.github/workflows/*.yml` |
| GitHub Action | `.github/action.yml` |
| Ansible Playbook | `**/playbook*.yml` |
| Ansible Tasks | `**/tasks/*.yml` |
| Docker Compose | `**/docker-compose*.yml` |
| Kustomization | `**/kustomization.yml` |
| Helmfile | `**/helmfile.yml` |
| CircleCI | `.circleci/config.yml` |

---

## Tips & Tricks

### General Workflow

```
1. Open Neovim in a project directory:  nvim .
2. Dashboard loads — press 'f' to find files or 'r' for recent
3. <leader>e  to open the file explorer
4. <leader>ff to fuzzy-find files, <leader>fg for live grep
5. gd / gr / K for LSP navigation while editing
6. <leader>gg for Neogit or <leader>gG for LazyGit
7. <C-\>      to toggle a floating terminal
```

### Multi-cursor Workflow
Use `cgn` (change next occurrence) to rename a word across a file:
1. Place cursor on a word
2. Press `*` to search all occurrences
3. Press `cgn` to change first occurrence
4. Press `.` (repeat) to change each subsequent one

### Quick Code Navigation
- `gd` → go to definition, then `<C-o>` to jump back
- `gr` → see all references in Telescope
- `<leader>fs` → jump to any symbol in the current file
- `<leader>fS` → search symbols across the whole project

### Terraform Tips
- Open a `.tf` file → LSP auto-starts
- `K` on a resource type shows documentation
- `<leader>ca` → code actions (import resource, etc.)
- `<C-\>` → open a terminal, run `terraform plan` inline
- `<leader>tT` → open persistent Terraform console

### Kubernetes / Helm Tips
- YAML files get Kubernetes schema auto-completion
- `K` on any YAML key shows the field description from the schema
- Helm files (`values.yaml`, `templates/*.yaml`) use `helm_ls`
- Use `<leader>fg` to grep across your entire chart directory

### Ansible Tips
- Playbook YAML files are auto-detected as `yaml.ansible` filetype (via `ansible-vim`)
- `ansiblels` activates automatically — get module name completion and validation
- Jinja2 template files (`.j2`, `.jinja2`) get syntax highlighting via `Vim-Jinja2-Syntax`
- `<leader>cf` formats the YAML on save
- `<leader>gG` (LazyGit) for managing playbook repositories

### Python Virtual Environments
- Open any Python file and press `<leader>pv` to pick a venv from Telescope
- Detects `.venv/`, `venv/`, `~/.virtualenvs/`, pyenv, Conda, Poetry, Pipenv automatically
- Switching venvs automatically updates `pyright` and `ruff` to use the chosen interpreter
- `<leader>pV` re-uses the last selected venv without showing the picker

### Database Browsing (DBee)
- Press `<leader>od` or run `:Dbee` to open the database UI.
- Add a PostgreSQL connection string such as `postgres://postgres:postgres@127.0.0.1:5432/postgres?sslmode=disable`.
- If your Postgres instance is running in Docker, make sure the container publishes the port to your host, for example `docker run -p 5432:5432 ... postgres`.
- Once connected, expand the connection in DBee's sidebar to browse schemas, tables, and run queries in scratch buffers.

### Python Debugging (DAP)
- `<leader>db` — toggle a breakpoint on the current line
- `<leader>dc` — start / continue the debug session (DAP UI opens automatically)
- `<leader>di` / `<leader>dn` / `<leader>do` — step into / over / out
- `<leader>dpm` — run the test method under cursor; `<leader>dpc` — run test class
- `<leader>du` — toggle the debug side panels (variables, call stack, watches)
- `<leader>de` — evaluate any expression or visual selection inline

### Go Tips
- Codelens shows test/run/tidy links in source files
- `<leader>cl` runs the codelens at cursor
- `goimports` runs on save (adds/removes imports automatically)
- `<leader>ca` → implement interface, fill struct, etc.

### Neogit (Git TUI) Tips
- `<leader>gg` to open Neogit
- `s` to stage file, `u` to unstage, `cc` to commit
- `?` in any Neogit buffer to see all available actions
- `<leader>gd` to open Diffview for side-by-side diffs

### Session Management
- Sessions are auto-saved per directory
- `<leader>qs` to restore the session for the current directory
- Useful when reopening a project — all your buffers/splits come back

---

## AI Assistant (Ollama)

This config includes **CodeCompanion** wired to a local **Ollama** instance. Your code never leaves your machine.

### Setup

```bash
# Install Ollama
brew install ollama        # macOS
# Linux: curl -fsSL https://ollama.com/install.sh | sh

# Pull the recommended model (Mistral AI, France — ~14 GB)
ollama pull codestral

# Start the daemon (once)
ollama serve
# Or auto-start at login:
brew services start ollama
```

> **Low RAM?** Use `llama3.1:8b` instead (~5 GB, still good for most tasks):
> ```bash
> ollama pull llama3.1:8b
> ```
> Then change `default = "codestral"` to `default = "llama3.1:8b"` in `lua/plugins/ai.lua`.

### Usage

**Chat mode** — open a persistent side panel:
```
<leader>ac    open/toggle chat
<leader>an    new chat session
```

In the chat buffer you can use slash commands to attach context:
```
/file        attach any file from the project
/buffer      attach an open buffer
/symbols     attach LSP symbols from the current file
```

**Inline mode** — generate or edit code at the cursor:
```
<leader>ai    open an inline prompt
```
Type your instruction (e.g. `add input validation`) and the AI edits the buffer directly. Accept/reject the diff.

**Visual selection actions** — select code, then:
```
<leader>ae    explain this code
<leader>af    fix this code
<leader>at    write tests for this
<leader>ar    review this code
```

**Commit messages:**
```
<leader>am    generate a commit message from staged diff
```

### Terraform / DevOps workflow

```
1. Open a .tf file
2. <leader>ac   — open AI chat
3. Ask: "add a security group rule for HTTPS ingress from 0.0.0.0/0"
   or:   "review this module for security issues"
   or:   "explain what this Ansible role does"
4. /file then select another .tf file to include as context
5. <leader>ai   — inline: select a resource block → <leader>af to fix it
```

### Switch models at any time
```vim
:CodeCompanionModels    " pick from all locally installed Ollama models
```
Or pull a new model from the terminal: `ollama pull <name>`

---

## Customisation

### Add a new LSP server
1. Open `lua/plugins/lsp.lua`
2. Add the Mason package name to `ensure_installed` in the Mason section (e.g. `"rust-analyzer"`)
3. Add settings using the Neovim 0.11 `vim.lsp.config` API inside the `nvim-lspconfig` config block:
```lua
vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = { command = "clippy" },
    },
  },
})
```
Mason + mason-lspconfig will auto-enable it via `vim.lsp.enable()` once installed.

### Add a new filetype formatter
Open `lua/plugins/editor.lua` and add to `formatters_by_ft`:
```lua
rust = { "rustfmt" },
```

### Change the colorscheme
Edit `lua/plugins/colorscheme.lua`. The current scheme is Tokyo Night. To switch:
```lua
-- Example: swap to nightfox
"EdenEast/nightfox.nvim",
config = function(_, opts)
  require("nightfox").setup(opts)
  vim.cmd.colorscheme("nightfox")
end
```
Also update `lua/plugins/statusline.lua` — lualine theme is set to `"tokyonight"` by name.

### Add personal keymaps
Add to `lua/core/keymaps.lua` or create a new file `lua/plugins/personal.lua`
that returns `{}` (no plugins) but sets up keymaps in its `config` block.

### Disable a plugin
In any plugin file, add `enabled = false` to the plugin spec:
```lua
{ "folke/noice.nvim", enabled = false, ... }
```

### Add custom snippets
Create `~/.config/nvim/snippets/<filetype>.json` in VS Code format — LuaSnip will pick them up automatically.

### Change AI model
Edit `lua/plugins/ai.lua` and update the `model.default` field:
```lua
schema = {
  model = {
    default = "llama3.1:8b",  -- or any model from: ollama list
  },
```
Then pull it: `ollama pull llama3.1:8b`

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Icons not showing | Install and configure a [Nerd Font](https://www.nerdfonts.com) in your terminal |
| LSP not starting | Run `:Mason` and check server is installed; `:LspInfo` for details |
| Slow startup | `:Lazy profile` to see which plugins are slow |
| Treesitter errors | `:TSUpdate` to rebuild parsers |
| Missing formatter | `:Mason` → search for the formatter → install it |
| Keybinding conflict | `:Telescope keymaps` to inspect all active keymaps |
| Cannot find files | `fd` and `ripgrep` are optional — telescope falls back to system `find`. Install them for better performance: `brew install fd ripgrep` |
| `s` doesn't substitute | `s` is remapped to flash.nvim jump. Use `cl` (change letter) or `cc` (change line) instead |
| LSP deprecation warnings | Ensure you are on Neovim ≥ 0.11; the config uses native `vim.lsp.config` and does not call `require('lspconfig')[server].setup()` |
| AI chat not responding | Ollama must be running: `ollama serve` (or `brew services start ollama`). Check with: `curl http://localhost:11434/api/tags` |
| AI model not found | Run `ollama pull codestral` (or `ollama list` to see what's installed) |
