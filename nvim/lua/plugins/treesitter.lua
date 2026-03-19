-- ============================================================================
-- Treesitter: Syntax highlighting, text objects, incremental selection
-- ============================================================================

return {
  {
    "nvim-treesitter/nvim-treesitter",
    version      = false,
    build        = ":TSUpdate",
    event        = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
    cmd          = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      -- ─── Parsers to install automatically ───────────────────────────────
      ensure_installed = {
        -- General development
        "bash", "c", "cpp", "css", "go", "gomod", "gosum", "gowork",
        "html", "java", "javascript", "json", "json5", "jsonc",
        "lua", "luadoc", "markdown", "markdown_inline",
        "python", "regex", "ruby", "rust", "sql",
        "toml", "tsx", "typescript", "vim", "vimdoc", "xml",

        -- DevOps specific
        "terraform",   -- Terraform/HCL
        "hcl",         -- HCL config files
        "dockerfile",  -- Dockerfiles
        "yaml",        -- Kubernetes, Ansible, CI/CD pipelines
        "ini",         -- Config files
        "make",        -- Makefiles
        "cmake",       -- CMake
        "nix",         -- Nix expressions
      },

      -- Auto-install missing parsers when opening a file
      auto_install = true,

      highlight    = {
        enable                            = true,
        additional_vim_regex_highlighting = false,
        -- Disable for large files
        disable = function(_, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats    = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then return true end
        end,
      },

      indent = { enable = true },

      -- ─── Incremental selection ───────────────────────────────────────────
      incremental_selection = {
        enable  = true,
        keymaps = {
          init_selection    = "<C-space>",
          node_incremental  = "<C-space>",
          scope_incremental = false,
          node_decremental  = "<BS>",
        },
      },

      -- ─── Text objects ────────────────────────────────────────────────────
      textobjects = {
        select = {
          enable    = true,
          lookahead = true,
          keymaps   = {
            ["af"] = { query = "@function.outer",  desc = "outer function" },
            ["if"] = { query = "@function.inner",  desc = "inner function" },
            ["ac"] = { query = "@class.outer",     desc = "outer class" },
            ["ic"] = { query = "@class.inner",     desc = "inner class" },
            ["aa"] = { query = "@parameter.outer", desc = "outer argument" },
            ["ia"] = { query = "@parameter.inner", desc = "inner argument" },
            ["ab"] = { query = "@block.outer",     desc = "outer block" },
            ["ib"] = { query = "@block.inner",     desc = "inner block" },
            ["al"] = { query = "@loop.outer",      desc = "outer loop" },
            ["il"] = { query = "@loop.inner",      desc = "inner loop" },
            ["ai"] = { query = "@conditional.outer", desc = "outer conditional" },
            ["ii"] = { query = "@conditional.inner", desc = "inner conditional" },
          },
        },
        move = {
          enable      = true,
          set_jumps   = true,
          goto_next_start = {
            ["]f"] = { query = "@function.outer",   desc = "Next function start" },
            ["]c"] = { query = "@class.outer",      desc = "Next class start" },
            ["]a"] = { query = "@parameter.inner",  desc = "Next argument start" },
          },
          goto_next_end = {
            ["]F"] = { query = "@function.outer",   desc = "Next function end" },
            ["]C"] = { query = "@class.outer",      desc = "Next class end" },
          },
          goto_previous_start = {
            ["[f"] = { query = "@function.outer",   desc = "Prev function start" },
            ["[c"] = { query = "@class.outer",      desc = "Prev class start" },
            ["[a"] = { query = "@parameter.inner",  desc = "Prev argument start" },
          },
          goto_previous_end = {
            ["[F"] = { query = "@function.outer",   desc = "Prev function end" },
            ["[C"] = { query = "@class.outer",      desc = "Prev class end" },
          },
        },
        swap = {
          enable = true,
          swap_next     = { ["<leader>ca"] = "@parameter.inner" },
          swap_previous = { ["<leader>cA"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)
    end,
  },

  -- ─── Show context at top of screen (e.g. current function name) ──────────
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts  = {
      enable         = true,
      max_lines      = 3,
      min_window_height = 20,
      mode           = "cursor",
      separator      = "─",
    },
    keys  = {
      {
        "<leader>ut",
        function() require("treesitter-context").toggle() end,
        desc = "Toggle treesitter context",
      },
    },
  },
}
