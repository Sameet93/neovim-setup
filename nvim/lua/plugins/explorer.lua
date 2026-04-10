-- ============================================================================
-- File Explorer: Neo-tree
-- ============================================================================

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd    = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
        end,
        desc = "Explorer (cwd)",
      },
      {
        "<leader>E",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.fn.expand("%:p:h") })
        end,
        desc = "Explorer (file dir)",
      },
      {
        "<leader>ge",
        function()
          require("neo-tree.command").execute({ source = "git_status", toggle = true })
        end,
        desc = "Git status explorer",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = true })
        end,
        desc = "Buffer explorer",
      },
    },
    deactivate = function() vim.cmd("Neotree close") end,
    init = function()
      -- Open neo-tree automatically if nvim was opened with a directory arg
      if vim.fn.argc(-1) == 1 then
        local stat = vim.uv.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    opts = {
      sources = { "filesystem", "buffers", "git_status", "document_symbols" },
      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            require("neo-tree.command").execute({ action = "close" })
          end,
        },
      },
      open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
      source_selector = {
        winbar = false,
      },
      filesystem = {
        bind_to_cwd          = false,
        follow_current_file  = { enabled = true, leave_dirs_open = false },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible         = false,
          hide_dotfiles   = false,
          hide_gitignored = false,
          hide_by_name    = {
            ".git", ".DS_Store", "node_modules",
            "__pycache__", ".terraform",
          },
          never_show = { ".DS_Store" },
        },
      },
      buffers = {
        follow_current_file = { enabled = true },
      },
      window = {
        width    = 35,
        position = "left",
        mappings = {
          ["<space>"] = "none",
          ["<CR>"]    = "open",
          ["P"]       = { "toggle_preview", config = { use_float = true, use_image_nvim = false } },
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              vim.fn.setreg("+", node:get_id(), "c")
              vim.notify("Copied path: " .. node:get_id(), vim.log.levels.INFO)
            end,
            desc = "Copy absolute path",
          },
        },
      },
      default_component_configs = {
        container = { enable_character_fade = true },
        indent = {
          with_expanders   = true,
          expander_collapsed = "",
          expander_expanded  = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open   = "",
          folder_empty  = "󰜌",
        },
        name      = { trailing_slash = false, use_git_status_colors = true },
        git_status = {
          symbols = {
            added     = "",
            modified  = "",
            deleted   = "✖",
            renamed   = "󰁕",
            untracked = "",
            ignored   = "",
            unstaged  = "󰄱",
            staged    = "",
            conflict  = "",
          },
        },
      },
    },
  },
}
