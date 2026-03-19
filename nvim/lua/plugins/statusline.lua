-- ============================================================================
-- Statusline (lualine) + Bufferline + Buffer management (mini.bufremove)
-- ============================================================================

return {

  -- ─── Statusline ──────────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event        = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons", "folke/tokyonight.nvim" },
    config = function()
      local icons = {
        diagnostics = { Error = " ", Warn = " ", Hint = " ", Info = " " },
        git         = { added = " ", modified = " ", removed = " " },
      }

      -- Use tokyonight theme; falls back to auto if not yet loaded (e.g. first install)
      local theme = pcall(require, "tokyonight") and "tokyonight" or "auto"

      require("lualine").setup({
        options = {
          theme            = theme,
          globalstatus     = true,
          component_separators = { left = "|", right = "|" },
          section_separators  = { left = "", right = "" },
          disabled_filetypes  = {
            statusline = { "dashboard", "alpha" },
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            { "branch", icon = "" },
          },
          lualine_c = {
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            {
              "filename",
              path    = 1,
              symbols = { modified = "  ", readonly = " ", unnamed = " " },
            },
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn  = icons.diagnostics.Warn,
                info  = icons.diagnostics.Info,
                hint  = icons.diagnostics.Hint,
              },
            },
          },
          lualine_x = {
            {
              "diff",
              symbols = {
                added    = icons.git.added,
                modified = icons.git.modified,
                removed  = icons.git.removed,
              },
              source = function()
                local gs = vim.b.gitsigns_status_dict
                if gs then
                  return { added = gs.added, modified = gs.changed, removed = gs.removed }
                end
              end,
            },
            { "encoding",   separator = "" },
            { "fileformat", separator = "" },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding  = { left = 0, right = 1 } },
          },
          lualine_z = {
            function() return " " .. os.date("%H:%M") end,
          },
        },
        extensions = { "neo-tree", "lazy", "toggleterm", "trouble", "mason" },
      })
    end,
  },

  -- ─── Buffer line (top tabs) ───────────────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    event        = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "echasnovski/mini.bufremove",
    },
    keys = {
      { "<S-h>",      "<cmd>BufferLineCyclePrev<CR>",           desc = "Prev buffer" },
      { "<S-l>",      "<cmd>BufferLineCycleNext<CR>",           desc = "Next buffer" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>",           desc = "Toggle pin buffer" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>",desc = "Close unpinned buffers" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>",         desc = "Close other buffers" },
      { "<leader>br", "<cmd>BufferLineCloseRight<CR>",          desc = "Close buffers to right" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<CR>",           desc = "Close buffers to left" },
    },
    opts = {
      options = {
        close_command       = function(n) require("mini.bufremove").delete(n, false) end,
        right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
        diagnostics         = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = { error = " ", warning = " " }
          local ret   = (diag.error   and icons.error   .. diag.error   .. " " or "")
                     .. (diag.warning and icons.warning .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype   = "neo-tree",
            text       = "  Explorer",
            highlight  = "Directory",
            text_align = "left",
          },
        },
        show_buffer_close_icons  = true,
        show_close_icon          = false,
        color_icons              = true,
        separator_style          = "thin",
      },
    },
  },

  -- ─── Smart buffer deletion ────────────────────────────────────────────────
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(
              ("Save changes to %q?"):format(vim.fn.bufname()),
              "&Yes\n&No\n&Cancel"
            )
            if choice == 1 then
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete buffer",
      },
      {
        "<leader>bD",
        function() require("mini.bufremove").delete(0, true) end,
        desc = "Delete buffer (force)",
      },
    },
  },
}
