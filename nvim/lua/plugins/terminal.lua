-- ============================================================================
-- Terminal: toggleterm.nvim with persistent named terminals
-- ============================================================================

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd      = { "ToggleTerm", "TermExec" },
    keys = {
      -- Default toggle
      { [[<C-\>]],     "<cmd>ToggleTerm<CR>",                              mode = { "n", "t" }, desc = "Toggle terminal" },
      -- Named terminal modes
      { "<leader>tf",  "<cmd>ToggleTerm direction=float<CR>",              desc = "Float terminal" },
      { "<leader>th",  "<cmd>ToggleTerm direction=horizontal<CR>",         desc = "Horizontal terminal" },
      { "<leader>tv",  "<cmd>ToggleTerm direction=vertical size=70<CR>",   desc = "Vertical terminal" },
      { "<leader>tt",  "<cmd>ToggleTerm direction=tab<CR>",                desc = "Tab terminal" },
      -- Named TUI terminals (trigger plugin load; config re-registers the actual handler)
      { "<leader>gG",  desc = "LazyGit" },
      { "<leader>tk",  desc = "K9s (Kubernetes)" },
      { "<leader>td",  desc = "LazyDocker" },
      { "<leader>tp",  desc = "Python REPL" },
      { "<leader>tm",  desc = "Htop (monitor)" },
      { "<leader>tT",  desc = "Terraform console" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then return 15
        elseif term.direction == "vertical" then return math.floor(vim.o.columns * 0.35)
        end
      end,
      open_mapping     = [[<c-\>]],
      hide_numbers     = true,
      shade_terminals  = false,
      start_in_insert  = true,
      insert_mappings  = true,
      terminal_mappings = true,
      persist_size     = true,
      persist_mode     = true,
      direction        = "float",
      close_on_exit    = true,
      shell            = vim.o.shell,
      auto_scroll      = true,
      float_opts = {
        border     = "curved",
        width      = function() return math.floor(vim.o.columns * 0.85) end,
        height     = function() return math.floor(vim.o.lines * 0.80) end,
        winblend   = 3,
        highlights = {
          border   = "FloatBorder",
          background = "NormalFloat",
        },
      },
      winbar = {
        enabled    = true,
        name_formatter = function(term)
          return term.name
        end,
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      local Terminal = require("toggleterm.terminal").Terminal

      -- ── LazyGit ──────────────────────────────────────────────────────────
      local lazygit = Terminal:new({
        cmd       = "lazygit",
        dir       = "git_dir",
        direction = "float",
        name      = "lazygit",
        float_opts = { border = "double" },
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>",
            { noremap = true, silent = true })
        end,
        on_close = function(_)
          vim.cmd("checktime") -- refresh file changes made in lazygit
        end,
      })
      vim.keymap.set("n", "<leader>gG", function() lazygit:toggle() end,
        { desc = "LazyGit" })

      -- ── K9s (Kubernetes TUI) ─────────────────────────────────────────────
      local k9s = Terminal:new({
        cmd       = "k9s",
        direction = "float",
        name      = "k9s",
        float_opts = { border = "curved" },
      })
      vim.keymap.set("n", "<leader>tk", function() k9s:toggle() end,
        { desc = "K9s (Kubernetes)" })

      -- ── LazyDocker ────────────────────────────────────────────────────────
      local lazydocker = Terminal:new({
        cmd       = "lazydocker",
        direction = "float",
        name      = "lazydocker",
        float_opts = { border = "double" },
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>",
            { noremap = true, silent = true })
        end,
      })
      vim.keymap.set("n", "<leader>td", function() lazydocker:toggle() end,
        { desc = "LazyDocker" })

      -- ── Python REPL ──────────────────────────────────────────────────────
      local python = Terminal:new({
        cmd       = "python3",
        direction = "horizontal",
        name      = "python",
      })
      vim.keymap.set("n", "<leader>tp", function() python:toggle() end,
        { desc = "Python REPL" })

      -- ── Htop ─────────────────────────────────────────────────────────────
      local htop = Terminal:new({
        cmd       = "htop",
        direction = "float",
        name      = "htop",
      })
      vim.keymap.set("n", "<leader>tm", function() htop:toggle() end,
        { desc = "Htop (monitor)" })

      -- ── Terraform console ────────────────────────────────────────────────
      local tf_console = Terminal:new({
        cmd       = "terraform console",
        direction = "horizontal",
        name      = "terraform",
        dir       = "%:p:h",
      })
      vim.keymap.set("n", "<leader>tT", function() tf_console:toggle() end,
        { desc = "Terraform console" })
    end,
  },
}
