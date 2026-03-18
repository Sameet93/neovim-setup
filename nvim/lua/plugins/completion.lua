-- ============================================================================
-- Completion: nvim-cmp + LuaSnip + friendly-snippets
-- ============================================================================

return {
  {
    "hrsh7th/nvim-cmp",
    version      = false,
    event        = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",    -- LSP source
      "hrsh7th/cmp-buffer",      -- Buffer words
      "hrsh7th/cmp-path",        -- Filesystem paths
      "hrsh7th/cmp-cmdline",     -- Cmdline completions
      "saadparwaiz1/cmp_luasnip",-- Snippet source
      {
        "L3MON4D3/LuaSnip",
        version      = "v2.*",
        build        = "make install_jsregexp",
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
            config = function()
              -- Load VS Code-style snippets (including community snippets)
              require("luasnip.loaders.from_vscode").lazy_load()
              -- Load DevOps-focused snipmate snippets if present
              require("luasnip.loaders.from_snipmate").lazy_load()
            end,
          },
        },
        opts = {
          history              = true,
          delete_check_events  = "TextChanged",
          region_check_events  = "CursorMoved",
        },
        keys = {
          {
            "<Tab>",
            function()
              return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<Tab>"
            end,
            expr    = true, silent = true, mode = "i",
          },
          { "<Tab>",   function() require("luasnip").jump(1)  end, mode = "s" },
          { "<S-Tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
        },
      },
    },
    opts = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      -- Check if there are characters before the cursor (no whitespace)
      local has_words_before = function()
        local unpack_ = unpack or table.unpack
        local line, col = unpack_(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
          and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      -- Kind icons (matches common VS Code icons)
      local kind_icons = {
        Array         = " ",  Boolean      = "󰨙 ", Class       = " ",
        Color         = " ",  Constant     = "󰏿 ", Constructor = " ",
        Enum          = " ",  EnumMember   = " ", Event       = " ",
        Field         = " ",  File         = " ", Folder      = " ",
        Function      = "󰊕 ", Interface    = " ", Key         = " ",
        Keyword       = " ",  Method       = "󰊕 ", Module      = " ",
        Namespace     = "󰦮 ", Null         = "󰟢 ", Number      = "󰎠 ",
        Object        = " ",  Operator     = " ", Package     = " ",
        Property      = " ",  Reference    = " ", Snippet     = " ",
        String        = " ",  Struct       = "󰆼 ", Text        = " ",
        TypeParameter = " ",  Unit         = " ", Value       = " ",
        Variable      = "󰀫 ",
      }

      return {
        completion   = { completeopt = "menu,menuone,noinsert" },
        snippet      = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered({ border = "rounded", winhighlight = "Normal:CmpNormal" }),
          documentation = cmp.config.window.bordered({ border = "rounded" }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"]     = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"]     = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          -- Confirm with Enter; S-Enter replaces current word
          ["<CR>"]  = cmp.mapping.confirm({ select = true }),
          ["<S-CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
          -- Tab: cycle completions or jump through snippet placeholders
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "path",     priority = 500 },
          { name = "buffer",   priority = 250,
            option = {
              get_bufnrs = function()
                -- Complete from all visible buffers
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
              end,
            },
          },
        }),
        formatting = {
          expandable_indicator = true,
          format = function(entry, item)
            if kind_icons[item.kind] then
              item.kind = kind_icons[item.kind] .. item.kind
            end
            -- Source badge
            local source_names = {
              nvim_lsp = "[LSP]",
              luasnip  = "[Snip]",
              buffer   = "[Buf]",
              path     = "[Path]",
              cmdline  = "[Cmd]",
            }
            item.menu = source_names[entry.source.name] or ""

            -- Truncate long entries
            local max_width = 50
            if #item.abbr > max_width then
              item.abbr = item.abbr:sub(1, max_width - 1) .. "…"
            end
            return item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
      }
    end,
    config = function(_, opts)
      local cmp = require("cmp")
      cmp.setup(opts)

      -- Cmdline completions for '/' and '?'
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      -- Cmdline completions for ':'
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "cmdline", option = { ignore_cmds = { "Man", "!" } } } }
        ),
      })

      -- Custom highlight for ghost text
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
    end,
  },
}
