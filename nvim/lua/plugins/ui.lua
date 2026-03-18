-- ============================================================================
-- UI Enhancements: notifications, command palette, dashboard, indent, which-key
-- ============================================================================

return {

  -- ─── Icons (required by many plugins) ────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ─── Better notifications ────────────────────────────────────────────────
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss notifications",
      },
    },
    opts = {
      stages       = "static",
      timeout      = 3000,
      render       = "compact",
      top_down     = false,
      max_height   = function() return math.floor(vim.o.lines * 0.75) end,
      max_width    = function() return math.floor(vim.o.columns * 0.75) end,
      on_open      = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
    init = function()
      vim.notify = require("notify")
    end,
  },

  -- ─── Noice: UI overhaul for cmdline, messages, popups ────────────────────
  {
    "folke/noice.nvim",
    event        = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    keys = {
      { "<S-Enter>",   function() require("noice").redirect(vim.fn.getcmdline()) end,                       mode = "c", desc = "Redirect cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end,                                          desc = "Noice: last message" },
      { "<leader>snh", function() require("noice").cmd("history") end,                                       desc = "Noice: message history" },
      { "<leader>sna", function() require("noice").cmd("all") end,                                           desc = "Noice: all messages" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end,                                       desc = "Noice: dismiss all" },
      { "<c-f>",       function() if not require("noice.lsp").scroll(4)  then return "<c-f>" end end,        silent = true, expr = true, desc = "Scroll forward",  mode = { "i", "n", "s" } },
      { "<c-b>",       function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end,        silent = true, expr = true, desc = "Scroll backward", mode = { "i", "n", "s" } },
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"]                  = true,
          ["cmp.entry.get_documentation"]                    = true,
        },
      },
      routes = {
        -- Route short-lived messages to mini view
        {
          filter = {
            event = "msg_show",
            any   = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
        -- Suppress common noisy messages
        { filter = { event = "msg_show", find = "written" },      opts = { skip = true } },
        { filter = { event = "msg_show", find = "^/" },            opts = { skip = true } },
      },
      presets = {
        bottom_search         = true,
        command_palette       = true,
        long_message_to_split = true,
        inc_rename            = true,
      },
    },
  },

  -- ─── Dashboard ───────────────────────────────────────────────────────────
  {
    "goolord/alpha-nvim",
    event        = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha     = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "                                                      ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                      ",
        "            DevOps IDE — powered by lazy.nvim         ",
        "                                                      ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file",       "<cmd>Telescope find_files<CR>"),
        dashboard.button("n", "  New file",        "<cmd>ene <BAR> startinsert<CR>"),
        dashboard.button("r", "  Recent files",    "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "  Live grep",       "<cmd>Telescope live_grep<CR>"),
        dashboard.button("s", "  Restore session", "<cmd>lua require('persistence').load()<CR>"),
        dashboard.button("l", "󰒲  Lazy",            "<cmd>Lazy<CR>"),
        dashboard.button("m", "  Mason",           "<cmd>Mason<CR>"),
        dashboard.button("q", "  Quit",            "<cmd>qa<CR>"),
      }

      dashboard.section.footer.opts.hl = "AlphaFooter"
      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"

      alpha.setup(dashboard.opts)

      -- Show startup stats in footer
      vim.api.nvim_create_autocmd("User", {
        once    = true,
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms    = math.floor(stats.startuptime * 100 + 0.5) / 100
          dashboard.section.footer.val = "⚡ "
            .. stats.loaded .. "/" .. stats.count
            .. " plugins loaded in " .. ms .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  -- ─── Indent guides ───────────────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main  = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts  = {
      indent  = { char = "│", tab_char = "│" },
      scope   = { enabled = false },
      exclude = {
        filetypes = {
          "help", "alpha", "dashboard", "neo-tree", "Trouble", "trouble",
          "lazy", "mason", "notify", "toggleterm",
        },
      },
    },
  },

  -- ─── Active indent scope highlight ───────────────────────────────────────
  {
    "echasnovski/mini.indentscope",
    version = false,
    event   = { "BufReadPost", "BufNewFile" },
    opts    = {
      symbol  = "│",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern  = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "trouble", "lazy", "mason", "notify", "toggleterm" },
        callback = function() vim.b.miniindentscope_disable = true end,
      })
    end,
  },

  -- ─── Keybinding hints ────────────────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = {
      icons    = { mappings = true },
      plugins  = { spelling = { enabled = true, suggestions = 20 } },
      win      = { border = "rounded" },
      spec = {
        { "<leader>b",  group = "buffer" },
        { "<leader>c",  group = "code/format" },
        { "<leader>d",  group = "diagnostics" },
        { "<leader>f",  group = "find/files" },
        { "<leader>g",  group = "git" },
        { "<leader>gh", group = "git hunks" },
        { "<leader>q",  group = "session" },
        { "<leader>s",  group = "splits/search&replace" },
        { "<leader>sn", group = "noice" },
        { "<leader>t",  group = "terminal/tabs" },
        { "<leader>u",  group = "ui" },
        { "<leader>w",  group = "save" },
        { "<leader>x",  group = "trouble/todo" },
        { "g",          group = "goto" },
        { "]",          group = "next" },
        { "[",          group = "prev" },
        { "z",          group = "fold" },
      },
    },
  },

  -- ─── Colour code preview ─────────────────────────────────────────────────
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts  = {
      user_default_options = {
        RGB      = true,
        RRGGBB   = true,
        names    = false,
        css      = true,
        css_fn   = true,
        mode     = "background",
        tailwind = false,
        virtualtext = "■",
      },
    },
    config = function(_, opts)
      require("colorizer").setup(opts)
    end,
  },
}
