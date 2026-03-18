-- ============================================================================
-- Git: gitsigns (gutter) + Neogit (TUI) + Diffview (diffs/history)
-- ============================================================================

return {

  -- ─── Git gutter signs & hunk operations ──────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts  = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      signs_staged = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
      },
      signcolumn                = true,
      numhl                     = false,
      linehl                    = false,
      word_diff                 = false,
      watch_gitdir              = { follow_files = true },
      attach_to_untracked       = true,
      current_line_blame        = false, -- toggle with <leader>gtb
      current_line_blame_opts   = {
        virt_text         = true,
        virt_text_pos     = "eol",
        delay             = 800,
        ignore_whitespace = false,
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- ── Hunk navigation ───────────────────────────────────────────────
        map("n", "]h", function()
          if vim.wo.diff then vim.cmd.normal({ "]c", bang = true })
          else gs.nav_hunk("next") end
        end, "Next hunk")

        map("n", "[h", function()
          if vim.wo.diff then vim.cmd.normal({ "[c", bang = true })
          else gs.nav_hunk("prev") end
        end, "Prev hunk")

        map("n", "]H", function() gs.nav_hunk("last")  end, "Last hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First hunk")

        -- ── Hunk actions ─────────────────────────────────────────────────
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>",  "Stage hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>",  "Reset hunk")
        map("n",          "<leader>ghS", gs.stage_buffer,             "Stage buffer")
        map("n",          "<leader>ghu", gs.undo_stage_hunk,          "Undo stage hunk")
        map("n",          "<leader>ghR", gs.reset_buffer,             "Reset buffer")
        map("n",          "<leader>ghp", gs.preview_hunk_inline,      "Preview hunk (inline)")
        map("n",          "<leader>ghP", gs.preview_hunk,             "Preview hunk (float)")
        map("n",          "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n",          "<leader>ghB", function() gs.blame() end,   "Blame buffer")
        map("n",          "<leader>ghd", gs.diffthis,                 "Diff this")
        map("n",          "<leader>ghD", function() gs.diffthis("~") end, "Diff this (against last commit)")

        -- ── Toggles ───────────────────────────────────────────────────────
        map("n", "<leader>gtb", gs.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>gtd", gs.toggle_deleted,            "Toggle show deleted")

        -- ── Text object ───────────────────────────────────────────────────
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
      end,
    },
  },

  -- ─── Neogit: Git TUI (like Magit for Emacs) ──────────────────────────────
  {
    "NeogitOrg/neogit",
    cmd          = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>",              desc = "Neogit status" },
      { "<leader>gc", "<cmd>Neogit commit<CR>",       desc = "Git commit" },
      { "<leader>gp", "<cmd>Neogit pull<CR>",         desc = "Git pull" },
      { "<leader>gP", "<cmd>Neogit push<CR>",         desc = "Git push" },
      { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "Git branches" },
      { "<leader>gl", "<cmd>Telescope git_commits<CR>",  desc = "Git log" },
      { "<leader>gL", "<cmd>Telescope git_bcommits<CR>", desc = "Git log (buffer)" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>",   desc = "Git status (telescope)" },
    },
    opts = {
      integrations = {
        diffview  = true,
        telescope = true,
      },
      signs = {
        item   = { "", "" },
        section = { "", "" },
        hunk   = { "", "" },
      },
    },
  },

  -- ─── Diffview: side-by-side diffs & file history ─────────────────────────
  {
    "sindrets/diffview.nvim",
    cmd  = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd",  "<cmd>DiffviewOpen<CR>",               desc = "Diff view open" },
      { "<leader>gD",  "<cmd>DiffviewClose<CR>",              desc = "Diff view close" },
      { "<leader>gf",  "<cmd>DiffviewFileHistory %<CR>",      desc = "File history (current)" },
      { "<leader>gF",  "<cmd>DiffviewFileHistory<CR>",        desc = "File history (all)" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default            = { layout = "diff2_horizontal", winbar_info = true },
        file_history       = { layout = "diff2_horizontal", winbar_info = true },
      },
      file_panel = {
        listing_style       = "tree",
        win_config          = { width = 35 },
        tree_options        = { flatten_dirs = true },
      },
      hooks = {
        -- Close Neogit when Diffview opens
        diff_buf_read = function(_)
          vim.opt_local.wrap   = false
          vim.opt_local.list   = false
          vim.opt_local.colorcolumn = { "80" }
        end,
      },
    },
  },
}
