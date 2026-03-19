-- ============================================================================
-- Telescope: Fuzzy Finder
-- ============================================================================

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd          = "Telescope",
    version      = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build   = "make",
        -- Only enable if make is available; on locked-down work machines
        -- the C compilation may be blocked — telescope still works without it.
        enabled = vim.fn.executable("make") == 1,
        config  = function()
          pcall(require("telescope").load_extension, "fzf")
        end,
      },
      {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
          pcall(require("telescope").load_extension, "ui-select")
        end,
      },
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      -- Files
      { "<leader>ff", "<cmd>Telescope find_files<CR>",                                  desc = "Find files" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>",                                    desc = "Recent files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",                                   desc = "Live grep" },
      { "<leader>fw", "<cmd>Telescope grep_string<CR>",                                 desc = "Grep word under cursor" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",                                     desc = "Find buffer" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>",                                   desc = "Help tags" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>",                                     desc = "Keymaps" },
      { "<leader>fm", "<cmd>Telescope marks<CR>",                                       desc = "Marks" },
      { "<leader>fo", "<cmd>Telescope vim_options<CR>",                                 desc = "Vim options" },
      { "<leader>fc", "<cmd>Telescope colorscheme<CR>",                                 desc = "Colorscheme" },
      -- Diagnostics
      { "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<CR>",                         desc = "Buffer diagnostics" },
      { "<leader>fD", "<cmd>Telescope diagnostics<CR>",                                 desc = "Workspace diagnostics" },
      -- Symbols
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>",                        desc = "Document symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>",               desc = "Workspace symbols" },
      -- Git
      { "<leader>fG", "<cmd>Telescope git_commits<CR>",                                 desc = "Git commits" },
      { "<leader>fB", "<cmd>Telescope git_branches<CR>",                                desc = "Git branches" },
      -- Fuzzy search current buffer
      {
        "<leader>f/",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find(
            require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
          )
        end,
        desc = "Fuzzy find in buffer",
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions   = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix   = "   ",
          selection_caret = " ",
          entry_prefix    = "   ",
          path_display    = { "smart" },
          sorting_strategy = "ascending",
          layout_strategy  = "horizontal",
          layout_config   = {
            horizontal     = { prompt_position = "top", preview_width = 0.55 },
            vertical       = { mirror = false },
            width          = 0.87,
            height         = 0.80,
            preview_cutoff = 120,
          },
          file_ignore_patterns = {
            "node_modules/", ".git/", ".terraform/", "__pycache__/",
            "%.pyc", "dist/", "build/", ".DS_Store", "%.lock",
          },
          mappings = {
            i = {
              ["<C-j>"]    = actions.move_selection_next,
              ["<C-k>"]    = actions.move_selection_previous,
              ["<C-q>"]    = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Esc>"]    = actions.close,
              ["<C-u>"]    = false,
              ["<C-d>"]    = actions.delete_buffer,
              ["<C-s>"]    = actions.select_horizontal,
              ["<C-v>"]    = actions.select_vertical,
            },
            n = {
              ["q"]  = actions.close,
              ["dd"] = actions.delete_buffer,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            -- Only force fd if it is actually installed. When omitted, Telescope
            -- uses its own fallback chain: fd → rg --files → find (the last one
            -- is always available). Hardcoding fd breaks find_files on machines
            -- where fd is not in PATH (e.g. locked-down work environments).
            find_command = vim.fn.executable("fd") == 1
              and { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden", "--follow" }
              or (vim.fn.executable("rg") == 1
                and { "rg", "--files", "--hidden", "--glob", "!.git/" }
                or nil),
          },
          live_grep = {
            -- Only pass --hidden if rg supports it (it always does, but guard
            -- against rg being absent; Telescope will error with a clear message).
            additional_args = vim.fn.executable("rg") == 1
              and { "--hidden", "--glob", "!.git/" }
              or {},
          },
          buffers = {
            sort_lastused = true,
            sort_mru      = true,
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
          fzf = {
            fuzzy                   = true,
            override_generic_sorter = true,
            override_file_sorter    = true,
            case_mode               = "smart_case",
          },
        },
      })
    end,
  },
}
