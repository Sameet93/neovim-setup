-- ============================================================================
-- Colorscheme: Catppuccin Mocha
-- ============================================================================

return {
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000, -- load before all other plugins
    opts = {
      flavour          = "mocha",
      background       = { light = "latte", dark = "mocha" },
      transparent_background = false,
      show_end_of_buffer     = false,
      term_colors            = true,
      dim_inactive = {
        enabled    = false,
        shade      = "dark",
        percentage = 0.15,
      },
      styles = {
        comments    = { "italic" },
        conditionals = { "italic" },
        keywords    = { "bold" },
        functions   = {},
        variables   = {},
      },
      integrations = {
        cmp             = true,
        gitsigns        = true,
        neotree         = true,
        telescope       = { enabled = true },
        treesitter      = true,
        notify          = true,
        lsp_trouble     = true,
        which_key       = true,
        indent_blankline = { enabled = true, scope_color = "lavender", colored_indent_levels = false },
        bufferline      = true,
        mason           = true,
        noice           = true,
        mini            = { enabled = true },
        native_lsp = {
          enabled       = true,
          virtual_text  = { errors = { "italic" }, hints = { "italic" }, warnings = { "italic" }, information = { "italic" } },
          underlines    = { errors = { "underline" }, hints = { "underline" }, warnings = { "underline" }, information = { "underline" } },
          inlay_hints   = { background = true },
        },
        illuminate = { enabled = true, lsp = false },
        ufo        = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
