-- ============================================================================
-- Neovim Configuration Entry Point
-- ============================================================================

-- Set leader keys BEFORE loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable default providers we don't need (speeds up startup)
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- ============================================================================
-- Bootstrap lazy.nvim (plugin manager)
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit...", "" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Load core configuration (before plugins)
-- ============================================================================
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- ============================================================================
-- Setup lazy.nvim — auto-imports all files from lua/plugins/
-- ============================================================================
require("lazy").setup({
  { import = "plugins" },
}, {
  defaults = {
    lazy = false,
    version = false, -- use latest git commits
  },
  install = {
    colorscheme = { "tokyonight", "habamax" },
  },
  rocks = {
    enabled = false, -- no plugins use luarocks; avoids hererocks bootstrap error
  },
  checker = {
    enabled = true,
    notify = false, -- silent auto-check for updates
  },
  change_detection = {
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded",
    backdrop = 60,
  },
})
