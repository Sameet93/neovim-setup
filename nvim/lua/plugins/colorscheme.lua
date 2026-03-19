-- ============================================================================
-- Colorscheme: Tokyo Night
-- ============================================================================

return {
  {
    "folke/tokyonight.nvim",
    priority = 1000, -- load before all other plugins
    opts = {
      style           = "night",   -- night | storm | day | moon
      light_style     = "day",
      transparent     = false,
      terminal_colors = true,
      styles = {
        comments    = { italic = true },
        keywords    = { bold   = true },
        functions   = {},
        variables   = {},
        sidebars    = "dark",
        floats      = "dark",
      },
      sidebars = { "qf", "help", "terminal", "neo-tree", "trouble", "lazy", "mason" },
      day_brightness       = 0.3,
      hide_inactive_statusline = false,
      dim_inactive         = false,
      lualine_bold         = true,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
