-- ============================================================================
-- Core Keymaps
-- ============================================================================
-- Note: Plugin-specific keymaps are defined in their respective plugin files.
-- LSP keymaps are set up in on_attach inside lua/plugins/lsp.lua.
-- ============================================================================

local map = vim.keymap.set

-- ─── Windows ───────────────────────────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows with arrows
map("n", "<C-Up>",    "<cmd>resize -2<CR>",          { desc = "Decrease window height" })
map("n", "<C-Down>",  "<cmd>resize +2<CR>",          { desc = "Increase window height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Splits
map("n", "<leader>sv", "<C-w>v",      { desc = "Split vertically" })
map("n", "<leader>sh", "<C-w>s",      { desc = "Split horizontally" })
map("n", "<leader>se", "<C-w>=",      { desc = "Equalize split sizes" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- ─── Buffers ───────────────────────────────────────────────────────────────
-- (cycle via bufferline keys: <S-h> / <S-l> defined in plugins/statusline.lua)
map("n", "<leader>ba", "<cmd>%bdelete<CR>",    { desc = "Close all buffers" })

-- ─── Tabs ──────────────────────────────────────────────────────────────────
map("n", "<leader>to", "<cmd>tabnew<CR>",   { desc = "New tab" })
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tn", "<cmd>tabn<CR>",     { desc = "Next tab" })
map("n", "<leader>tp", "<cmd>tabp<CR>",     { desc = "Prev tab" })

-- ─── Editing ───────────────────────────────────────────────────────────────
-- Stay in indent mode after shifting
map("v", "<", "<gv", { desc = "Shift left & reselect" })
map("v", ">", ">gv", { desc = "Shift right & reselect" })

-- Move selected lines up/down
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("n", "<A-j>", "<cmd>m .+1<CR>==",  { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==",  { desc = "Move line up" })

-- Paste without overwriting register
map("v", "p", '"_dP', { desc = "Paste without yanking selection" })
map("x", "p", '"_dP', { desc = "Paste without yanking selection" })

-- Delete without yanking (use x register)
map({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete to void register" })

-- Select all
map("n", "<C-a>", "gg<S-v>G", { desc = "Select all" })

-- ─── Navigation ────────────────────────────────────────────────────────────
-- Better j/k with line wrap
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Keep cursor centred when jumping
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centred)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centred)" })
map("n", "n",     "nzzzv",   { desc = "Next match (centred)" })
map("n", "N",     "Nzzzv",   { desc = "Prev match (centred)" })

-- ─── Diagnostics ───────────────────────────────────────────────────────────
map("n", "[d", vim.diagnostic.goto_prev,  { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next,  { desc = "Next diagnostic" })
map("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- ─── Search ────────────────────────────────────────────────────────────────
map("n", "<leader>nh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
map({ "n", "v" }, "<leader>/", "gcc", { remap = true, desc = "Toggle comment" })

-- ─── File / Save ───────────────────────────────────────────────────────────
map("n", "<C-s>",       "<cmd>w<CR>",   { desc = "Save file" })
map("i", "<C-s>",       "<Esc><cmd>w<CR>a", { desc = "Save file" })
map("n", "<leader>w",   "<cmd>w<CR>",   { desc = "Save file" })
map("n", "<leader>q",   "<cmd>q<CR>",   { desc = "Quit" })
map("n", "<leader>Q",   "<cmd>qa!<CR>", { desc = "Force quit all" })

-- ─── Terminal ──────────────────────────────────────────────────────────────
-- Exit terminal mode with double Escape
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
-- Navigate from terminal splits
map("t", "<C-h>", "<cmd>wincmd h<CR>", { desc = "Terminal: move left" })
map("t", "<C-j>", "<cmd>wincmd j<CR>", { desc = "Terminal: move down" })
map("t", "<C-k>", "<cmd>wincmd k<CR>", { desc = "Terminal: move up" })
map("t", "<C-l>", "<cmd>wincmd l<CR>", { desc = "Terminal: move right" })

-- ─── UI Toggles ────────────────────────────────────────────────────────────
map("n", "<leader>uw", "<cmd>set wrap!<CR>",            { desc = "Toggle word wrap" })
map("n", "<leader>us", "<cmd>set spell!<CR>",           { desc = "Toggle spell check" })
map("n", "<leader>un", "<cmd>set relativenumber!<CR>",  { desc = "Toggle relative numbers" })
map("n", "<leader>uc", "<cmd>set cursorline!<CR>",      { desc = "Toggle cursor line" })
