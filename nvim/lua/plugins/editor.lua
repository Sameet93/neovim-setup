-- ============================================================================
-- Editor Plugins: formatting, linting, pairs, comments, surround, folds,
--                 search/replace, todo comments, session, and more
-- ============================================================================

return {

  -- ─── Auto pairs ──────────────────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = {
      check_ts         = true,
      ts_config        = { lua = { "string" }, javascript = { "template_string" } },
      fast_wrap        = {
        map            = "<M-e>",
        chars          = { "{", "[", "(", '"', "'" },
        pattern        = [=[[%'%"%)%>%]%)%}%,]]=],
        end_key        = "$",
        cursor_pos_before = false,
        keys           = "qwertyuiopzxcvbnmasdfghjkl",
        manual_position = true,
        highlight      = "Search",
        highlight_grey = "Comment",
      },
    },
    config = function(_, opts)
      require("nvim-autopairs").setup(opts)
      -- Connect autopairs with nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- ─── Comments ────────────────────────────────────────────────────────────
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      require("Comment").setup({
        -- tsx/jsx aware comment toggling
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = { enable_autocmd = false },
  },

  -- ─── Surround (cs" ', ds', ys"…) ─────────────────────────────────────────
  {
    "kylechui/nvim-surround",
    version = "*",
    event   = "VeryLazy",
    opts    = {},
  },

  -- ─── Auto-detect tab/space settings ─────────────────────────────────────
  {
    "tpope/vim-sleuth",
    event = { "BufReadPre", "BufNewFile" },
  },

  -- ─── Highlight word under cursor ─────────────────────────────────────────
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts  = {
      delay               = 200,
      large_file_cutoff   = 2000,
      large_file_overrides = { providers = { "lsp" } },
      providers           = { "lsp", "treesitter", "regex" },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)
      -- Navigate between references
      local function map(key, dir, buf)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " reference", buffer = buf })
      end
      map("]]", "next")
      map("[[", "prev")
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          map("]]", "next", buf)
          map("[[", "prev", buf)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next reference" },
      { "[[", desc = "Prev reference" },
    },
  },

  -- ─── Formatting (conform.nvim) ────────────────────────────────────────────
  {
    "stevearc/conform.nvim",
    lazy = true,
    event = { "BufWritePre" },
    cmd   = { "ConformInfo" },
    keys  = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        mode = { "n", "v" },
        desc = "Format buffer/selection",
      },
    },
    opts = {
      formatters_by_ft = {
        lua        = { "stylua" },
        python     = { "isort", "black" },
        -- ruff can replace isort+black; uncomment to prefer it:
        -- python  = { "ruff_fix", "ruff_format" },
        go         = { "goimports", "gofmt" },
        sh         = { "shfmt" },
        bash       = { "shfmt" },
        zsh        = { "shfmt" },
        terraform  = { "terraform_fmt" },
        tf         = { "terraform_fmt" },
        json       = { "prettier" },
        jsonc      = { "prettier" },
        yaml       = { "prettier" },
        markdown   = { "prettier" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        html       = { "prettier" },
        css        = { "prettier" },
        -- DevOps templates left for LSP formatting
        dockerfile = {},
      },
      format_on_save = {
        timeout_ms   = 500,
        lsp_fallback = true,
      },
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2", "-ci" }, -- 2-space indent + case indent
        },
      },
    },
  },

  -- ─── Linting (nvim-lint) ─────────────────────────────────────────────────
  {
    "mfussenegger/nvim-lint",
    event  = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        sh           = { "shellcheck" },
        bash         = { "shellcheck" },
        dockerfile   = { "hadolint" },
        terraform    = { "tflint" },
        yaml         = { "yamllint" },
        ["yaml.ansible"] = { "ansiblelint" },  -- Ansible playbooks/roles
        python       = { "flake8" },
      }

      -- Lint on enter, write, and leaving insert
      local group = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group    = group,
        callback = function()
          -- Don't lint huge files
          if vim.fn.getfsize(vim.api.nvim_buf_get_name(0)) > 1024 * 1024 then return end
          require("lint").try_lint()
        end,
      })
    end,
  },

  -- ─── Folding (nvim-ufo) ───────────────────────────────────────────────────
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event        = "BufReadPost",
    opts = {
      preview = {
        win_config = { border = "rounded", winhighlight = "Normal:Normal", winblend = 0 },
      },
      provider_selector = function(_, filetype, _)
        -- Use LSP for these languages (richer fold info)
        local lsp_filetypes = { "go", "python", "typescript", "javascript", "lua", "terraform" }
        if vim.tbl_contains(lsp_filetypes, filetype) then
          return { "lsp", "indent" }
        end
        return { "treesitter", "indent" }
      end,
    },
    keys = {
      { "zR",  function() require("ufo").openAllFolds()         end, desc = "Open all folds" },
      { "zM",  function() require("ufo").closeAllFolds()        end, desc = "Close all folds" },
      { "zr",  function() require("ufo").openFoldsExceptKinds() end, desc = "Fold less" },
      { "zm",  function() require("ufo").closeFoldsWith()       end, desc = "Fold more" },
      { "zp",  function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold" },
    },
  },

  -- ─── Search & Replace across project (Spectre) ───────────────────────────
  {
    "nvim-pack/nvim-spectre",
    build = false,
    cmd   = "Spectre",
    opts  = { open_cmd = "noswapfile vnew" },
    keys  = {
      { "<leader>sr",  function() require("spectre").toggle() end,                                    desc = "Search & Replace (Spectre)" },
      { "<leader>sw",  function() require("spectre").open_visual({ select_word = true }) end,         desc = "Search word under cursor" },
      { "<leader>sw",  function() require("spectre").open_visual() end, mode = "v",                   desc = "Search selection" },
      { "<leader>sf",  function() require("spectre").open_file_search({ select_word = true }) end,    desc = "Search in file" },
    },
  },

  -- ─── Better quickfix list ─────────────────────────────────────────────────
  { "kevinhwang91/nvim-bqf", ft = "qf", opts = {} },

  -- ─── Highlight TODO/FIXME/NOTE/HACK comments ─────────────────────────────
  {
    "folke/todo-comments.nvim",
    cmd          = { "TodoTrouble", "TodoTelescope" },
    event        = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs     = false,
      keywords  = {
        FIX  = { icon = " ", color = "error",   alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = "󰅒 ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint",    alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test",   alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end,                           desc = "Next todo" },
      { "[t",         function() require("todo-comments").jump_prev() end,                           desc = "Prev todo" },
      { "<leader>xt", "<cmd>Trouble todo toggle<CR>",                                               desc = "Todo list (Trouble)" },
      { "<leader>xT", "<cmd>Trouble todo toggle filter={tag={TODO,FIX,FIXME}}<CR>",                 desc = "Todo/Fix/Fixme" },
      { "<leader>ft", "<cmd>TodoTelescope<CR>",                                                     desc = "Find todos" },
    },
  },

  -- ─── Session persistence ─────────────────────────────────────────────────
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts  = { options = vim.opt.sessionoptions:get() },
    keys  = {
      { "<leader>qs", function() require("persistence").load()                end, desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop()                end, desc = "Stop session saving" },
    },
  },

  -- ─── Flash: fast navigation / leap-style motions ─────────────────────────
  {
    "folke/flash.nvim",
    event  = "VeryLazy",
    opts   = {},
    keys   = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump()              end, desc = "Flash jump" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter()        end, desc = "Flash treesitter" },
      { "r",     mode = "o",               function() require("flash").remote()             end, desc = "Remote flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Flash treesitter search" },
      { "<C-s>", mode = "c",               function() require("flash").toggle()             end, desc = "Toggle flash search" },
    },
  },

  -- ─── Better f/t motions with hints ───────────────────────────────────────
  {
    "echasnovski/mini.move",
    version = false,
    event   = "VeryLazy",
    opts    = {
      mappings = {
        left       = "<M-h>", right    = "<M-l>",
        down       = "<M-j>", up       = "<M-k>",
        line_left  = "<M-h>", line_right = "<M-l>",
        line_down  = "<M-j>", line_up    = "<M-k>",
      },
    },
  },
}
