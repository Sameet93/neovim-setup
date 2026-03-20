-- ============================================================================
-- Autocommands
-- ============================================================================

local autocmd = vim.api.nvim_create_autocmd
local augroup = function(name)
  return vim.api.nvim_create_augroup("nvim_" .. name, { clear = true })
end

-- ─── Yank highlight ────────────────────────────────────────────────────────
autocmd("TextYankPost", {
  group   = augroup("yank_highlight"),
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- ─── Resize splits when terminal is resized ────────────────────────────────
autocmd("VimResized", {
  group    = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- ─── Go to last cursor position on file open ───────────────────────────────
autocmd("BufReadPost", {
  group    = augroup("last_cursor"),
  callback = function(event)
    local exclude = { "gitcommit", "gitrebase", "svn", "hgcommit" }
    local buf     = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then return end
    local mark   = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ─── Close certain filetypes with 'q' ──────────────────────────────────────
autocmd("FileType", {
  group   = augroup("close_with_q"),
  pattern = {
    "help", "lspinfo", "man", "notify", "qf", "spectre_panel",
    "startuptime", "tsplayground", "PlenaryTestPopup", "checkhealth",
    "fugitive", "git", "neotest-output", "neotest-summary",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", {
      buffer = event.buf, silent = true, desc = "Close window",
    })
  end,
})

-- ─── Disable auto-comment on new line ──────────────────────────────────────
autocmd("FileType", {
  group    = augroup("no_auto_comment"),
  pattern  = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- ─── Trim trailing whitespace on save ──────────────────────────────────────
autocmd("BufWritePre", {
  group    = augroup("trim_whitespace"),
  pattern  = "*",
  callback = function()
    local pos = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", pos)
  end,
})

-- ─── Extra filetype detections for DevOps files ────────────────────────────
autocmd({ "BufRead", "BufNewFile" }, {
  group   = augroup("devops_filetypes"),
  pattern = { "*.tf", "*.tfvars", "*.tfstate" },
  callback = function() vim.bo.filetype = "terraform" end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  group   = augroup("yaml_filetype"),
  pattern = { "*.yaml", "*.yml" },
  callback = function() vim.bo.filetype = "yaml" end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  group   = augroup("dockerfile_filetype"),
  pattern = { "Dockerfile*", "*.dockerfile" },
  callback = function() vim.bo.filetype = "dockerfile" end,
})

autocmd({ "BufRead", "BufNewFile" }, {
  group   = augroup("json_filetype"),
  pattern = { "*.json", "*.jsonc", "*.json5" },
  callback = function() vim.bo.filetype = "json" end,
})

-- ─── Wrap and spell in text filetypes ──────────────────────────────────────
autocmd("FileType", {
  group   = augroup("wrap_spell"),
  pattern = { "text", "markdown", "gitcommit" },
  callback = function()
    vim.opt_local.wrap   = true
    vim.opt_local.spell  = true
    vim.opt_local.spelllang = "en"
  end,
})

-- ─── Telescope: disable horizontal scroll shifting ─────────────────────────
-- scrolloff/sidescrolloff are window-local. The FileType event fires while
-- focus is still in the prompt window, so vim.opt_local targets the wrong
-- window. Instead: find every window that holds this buffer and set the
-- options directly via nvim_set_option_value with { win = win_id }.
autocmd("FileType", {
  group   = augroup("telescope_scroll"),
  pattern = { "TelescopePrompt", "TelescopeResults", "TelescopePreview" },
  callback = function(ev)
    -- Set on every window displaying this buffer (usually just one)
    for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
      vim.api.nvim_set_option_value("sidescrolloff", 0, { win = win })
      vim.api.nvim_set_option_value("scrolloff",     0, { win = win })
    end
    -- Also fire on WinEnter in case the window wasn't open yet when FileType fired
    local buf = ev.buf
    vim.api.nvim_create_autocmd("WinEnter", {
      once    = true,
      buffer  = buf,
      callback = function()
        local w = vim.api.nvim_get_current_win()
        if vim.api.nvim_win_get_buf(w) == buf then
          vim.api.nvim_set_option_value("sidescrolloff", 0, { win = w })
          vim.api.nvim_set_option_value("scrolloff",     0, { win = w })
        end
      end,
    })
  end,
})

-- ─── CodeCompanion chat buffer settings ────────────────────────────────────
-- The global wrap=false + sidescrolloff=8 causes long AI responses to scroll
-- sideways. Force sane reading defaults and disable nvim-cmp so it doesn't
-- pop up inside the chat (codecompanion has its own <C-_> completion).
autocmd("FileType", {
  group   = augroup("codecompanion_chat"),
  pattern = "codecompanion",
  callback = function()
    vim.opt_local.wrap          = true   -- wrap long AI responses
    vim.opt_local.sidescrolloff = 0      -- no horizontal scroll chasing cursor
    vim.opt_local.linebreak     = true   -- break at word boundaries
    vim.opt_local.spell         = false  -- no red squiggles in AI text
    -- Disable nvim-cmp in the chat buffer; codecompanion provides its own
    -- completion (<C-_>) for slash commands and context variables.
    local ok, cmp = pcall(require, "cmp")
    if ok then cmp.setup.buffer({ enabled = false }) end
  end,
})

-- ─── Auto-create parent directories when saving ────────────────────────────
autocmd("BufWritePre", {
  group    = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
