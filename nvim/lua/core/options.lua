-- ============================================================================
-- Core Neovim Options
-- ============================================================================

local opt = vim.opt

-- ─── Line Numbers ──────────────────────────────────────────────────────────
opt.number         = true   -- show absolute line number
opt.relativenumber = true   -- show relative line numbers
opt.numberwidth    = 4      -- width of number column

-- ─── Tabs & Indentation ────────────────────────────────────────────────────
opt.tabstop        = 2      -- visual spaces per tab
opt.softtabstop    = 2      -- spaces per tab in insert mode
opt.shiftwidth     = 2      -- spaces for auto-indent
opt.expandtab      = true   -- tabs → spaces
opt.autoindent     = true   -- copy indent from current line
opt.smartindent    = true   -- smart auto-indenting

-- ─── Line Wrapping ─────────────────────────────────────────────────────────
opt.wrap        = false   -- disable line wrap
opt.linebreak   = true    -- break at word boundaries if wrap is on
opt.breakindent = true    -- indent wrapped lines

-- ─── Search ────────────────────────────────────────────────────────────────
opt.ignorecase = true  -- case-insensitive search
opt.smartcase  = true  -- case-sensitive if uppercase used
opt.hlsearch   = true  -- highlight search results
opt.incsearch  = true  -- incremental search

-- ─── Cursor & Scrolling ────────────────────────────────────────────────────
opt.cursorline  = true  -- highlight current line
opt.scrolloff   = 8     -- keep 8 lines above/below cursor
opt.sidescrolloff = 8   -- keep 8 columns left/right of cursor

-- ─── Appearance ────────────────────────────────────────────────────────────
opt.termguicolors = true            -- enable 24-bit colours
opt.background    = "dark"
opt.signcolumn    = "yes"           -- always show sign column (prevents jumping)
opt.colorcolumn   = "120"           -- ruler at column 120
opt.showmode      = false           -- don't show -- INSERT -- (lualine does this)
opt.showcmd       = false
opt.laststatus    = 3               -- global statusline
opt.cmdheight     = 1

-- ─── Splits ────────────────────────────────────────────────────────────────
opt.splitright = true   -- vertical splits go right
opt.splitbelow = true   -- horizontal splits go below

-- ─── Files & Encoding ──────────────────────────────────────────────────────
opt.fileencoding = "utf-8"
opt.swapfile     = false   -- no swap files
opt.backup       = false   -- no backup files
opt.undofile     = true    -- persistent undo
opt.undodir      = vim.fn.stdpath("data") .. "/undodir"

-- ─── Performance & Updates ─────────────────────────────────────────────────
opt.updatetime  = 250   -- faster CursorHold / gitsigns update
opt.timeoutlen  = 300   -- faster which-key popup

-- ─── Completion ────────────────────────────────────────────────────────────
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight   = 15   -- max items in popup menu

-- ─── Clipboard ─────────────────────────────────────────────────────────────
-- Sync with system clipboard (requires xclip/xsel on Linux, pbcopy on macOS)
opt.clipboard = "unnamedplus"

-- ─── Mouse ─────────────────────────────────────────────────────────────────
opt.mouse = "a"   -- enable mouse in all modes

-- ─── Backspace ─────────────────────────────────────────────────────────────
opt.backspace = { "indent", "eol", "start" }

-- ─── Word Characters ───────────────────────────────────────────────────────
opt.iskeyword:append("-")   -- treat kebab-case as one word

-- ─── Folds (managed by nvim-ufo) ───────────────────────────────────────────
opt.foldcolumn    = "1"    -- show fold column
opt.foldlevel     = 99     -- open all folds by default
opt.foldlevelstart = 99
opt.foldenable    = true

-- ─── Misc ──────────────────────────────────────────────────────────────────
opt.virtualedit   = "block"    -- allow cursor past EOL in visual block mode
opt.conceallevel  = 2          -- hide * markup for bold/italic
opt.spelllang     = { "en" }
opt.confirm       = true       -- ask to save instead of failing
opt.list          = true       -- show invisible characters
opt.listchars     = {
  tab      = "» ",
  trail    = "·",
  nbsp     = "␣",
}
opt.fillchars = {
  eob       = " ",   -- no ~ on empty lines
  fold      = " ",
  foldopen  = "▾",
  foldclose = "▸",
  foldsep   = " ",
}

-- ─── Window title ──────────────────────────────────────────────────────────
opt.title    = true
opt.titlelen = 0

-- Ensure undo directory exists
vim.fn.mkdir(vim.fn.stdpath("data") .. "/undodir", "p")
