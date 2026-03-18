-- ============================================================================
-- LSP: Mason (installer) + nvim-lspconfig + DevOps server configurations
-- ============================================================================

return {

  -- ─── Mason: install & manage LSP servers, DAP, linters, formatters ───────
  {
    "williamboman/mason.nvim",
    cmd   = "Mason",
    build = ":MasonUpdate",
    keys  = { { "<leader>cm", "<cmd>Mason<CR>", desc = "Mason" } },
    opts  = {
      ensure_installed = {
        -- ── LSP servers ────────────────────────────────────────────────────
        "lua-language-server",        -- Lua (Neovim config)
        "bash-language-server",       -- Bash / Shell
        "pyright",                    -- Python
        "gopls",                      -- Go
        "yaml-language-server",       -- YAML (K8s, Ansible, CI/CD)
        "json-lsp",                   -- JSON
        "terraform-ls",               -- Terraform
        "ansible-language-server",    -- Ansible
        "helm-ls",                    -- Helm charts
        "dockerfile-language-server", -- Dockerfile
        "docker-compose-language-service",

        -- ── Formatters ─────────────────────────────────────────────────────
        "stylua",         -- Lua
        "shfmt",          -- Shell
        "black",          -- Python
        "isort",          -- Python imports
        "goimports",      -- Go imports
        "prettier",       -- JSON/YAML/Markdown/JS/TS/HTML/CSS
        "terraform-ls",   -- terraform fmt (via server)

        -- ── Linters ────────────────────────────────────────────────────────
        "shellcheck",     -- Bash linter
        "hadolint",       -- Dockerfile linter
        "tflint",         -- Terraform linter
        "yamllint",       -- YAML linter
        "flake8",         -- Python linter
        "ansiblelint",    -- Ansible linter
        "ruff",           -- Fast Python linter/formatter (Rust-based)

        -- ── Debug adapters ─────────────────────────────────────────────────
        "debugpy",        -- Python debug adapter (used by nvim-dap-python)
      },
      ui = {
        border = "rounded",
        icons  = {
          package_installed   = "✓",
          package_pending     = "➜",
          package_uninstalled = "✗",
        },
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)

      -- Auto-install any missing packages listed in ensure_installed
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf   = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local ok, p = pcall(mr.get_package, tool)
          if ok and not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },

  -- ─── Bridge between Mason and lspconfig ──────────────────────────────────
  {
    "williamboman/mason-lspconfig.nvim",
    lazy         = true,
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      automatic_installation = true,
    },
  },

  -- ─── Neovim lua API completions ──────────────────────────────────────────
  { "folke/neodev.nvim", opts = {} },

  -- ─── Core LSP configuration ──────────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event        = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "folke/neodev.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "b0o/SchemaStore.nvim",  -- comprehensive JSON/YAML schemas for jsonls + yamlls
    },
    config = function()

      -- ── Diagnostic display ───────────────────────────────────────────────
      vim.diagnostic.config({
        underline        = true,
        update_in_insert = false,
        severity_sort    = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
          },
        },
        virtual_text = {
          spacing = 4,
          source  = "if_many",
          prefix  = "●",
        },
        float = {
          border  = "rounded",
          source  = "always",
          style   = "minimal",
          header  = "",
          prefix  = "",
        },
      })

      -- ── Round hover/signature help borders ──────────────────────────────
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, { border = "rounded", max_width = 80 }
      )
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, { border = "rounded" }
      )

      -- ── Capabilities (with nvim-cmp) ─────────────────────────────────────
      local capabilities = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities()
      )
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false, lineFoldingOnly = true,
      }

      -- ── On-attach keymaps ────────────────────────────────────────────────
      local on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        -- Navigation
        map("gd",  vim.lsp.buf.definition,                           "Go to definition")
        map("gD",  vim.lsp.buf.declaration,                          "Go to declaration")
        map("gr",  "<cmd>Telescope lsp_references<CR>",              "References")
        map("gi",  vim.lsp.buf.implementation,                       "Go to implementation")
        map("gt",  vim.lsp.buf.type_definition,                      "Type definition")
        map("gI",  "<cmd>Telescope lsp_implementations<CR>",         "Implementations")

        -- Documentation
        map("K",    vim.lsp.buf.hover,           "Hover documentation")
        map("<C-k>", vim.lsp.buf.signature_help, "Signature help")

        -- Actions
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>rn", vim.lsp.buf.rename,       "Rename symbol")
        map("<leader>cf", function()
          require("conform").format({ async = true, lsp_fallback = true })
        end, "Format buffer")

        -- Workspace
        map("<leader>wa", vim.lsp.buf.add_workspace_folder,    "Add workspace folder")
        map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
        map("<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "List workspace folders")

        -- Codelens (run actions) — useful for Go tests, Terraform, etc.
        map("<leader>cl", vim.lsp.codelens.run, "Run codelens")

        -- Highlight references on cursor hold
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          buffer   = bufnr,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          buffer   = bufnr,
          callback = vim.lsp.buf.clear_references,
        })
      end

      -- ── Server definitions ───────────────────────────────────────────────
      local servers = {

        -- Lua
        lua_ls = {
          settings = {
            Lua = {
              runtime   = { version = "LuaJIT" },
              workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
              telemetry = { enable  = false },
              diagnostics = { globals = { "vim" } },
              completion  = { callSnippet = "Replace" },
            },
          },
        },

        -- Bash / Shell
        bashls = {
          filetypes = { "sh", "bash", "zsh" },
          settings  = {
            bashIde = {
              globPattern = "**/*@(.sh|.inc|.bash|.command)",
            },
          },
        },

        -- Python
        pyright = {
          settings = {
            python = {
              analysis = {
                autoSearchPaths     = true,
                useLibraryCodeForTypes = true,
                diagnosticMode      = "workspace",
                typeCheckingMode    = "basic",
              },
            },
          },
        },

        -- Go
        gopls = {
          settings = {
            gopls = {
              gofumpt     = true,
              codelenses  = {
                gc_details          = false,
                generate            = true,
                regenerate_cgo      = true,
                run_govulncheck     = true,
                test                = true,
                tidy                = true,
                upgrade_dependency  = true,
                vendor              = true,
              },
              hints = {
                assignVariableTypes    = true,
                compositeLiteralFields = true,
                compositeLiteralTypes  = true,
                constantValues         = true,
                functionTypeParameters = true,
                parameterNames         = true,
                rangeVariableTypes     = true,
              },
              analyses = {
                fieldalignment = true,
                nilness        = true,
                unusedparams   = true,
                unusedwrite    = true,
                useany         = true,
              },
              usePlaceholders        = true,
              completeUnimported     = true,
              staticcheck            = true,
              directoryFilters       = { "-.git", "-.vscode", "-.idea", "-node_modules" },
              semanticTokens         = true,
            },
          },
        },

        -- YAML (Kubernetes, Ansible, GitHub Actions, Docker Compose, etc.)
        yamlls = {
          -- SchemaStore provides 500+ schemas; injected via on_new_config so the
          -- plugin is guaranteed to be loaded before the server starts.
          on_new_config = function(new_config)
            local ok, ss = pcall(require, "schemastore")
            if ok then
              new_config.settings.yaml.schemas = ss.yaml.schemas()
            end
          end,
          settings = {
            yaml = {
              keyOrdering = false,
              format      = { enable = true },
              validate    = true,
              -- Disable built-in schemaStore; SchemaStore.nvim replaces it
              schemaStore = { enable = false, url = "" },
            },
          },
        },

        -- JSON
        jsonls = {
          -- SchemaStore provides 500+ JSON schemas (package.json, tsconfig, etc.)
          on_new_config = function(new_config)
            local ok, ss = pcall(require, "schemastore")
            if ok then
              new_config.settings.json.schemas = ss.json.schemas()
            else
              new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            end
          end,
          settings = {
            json = {
              format   = { enable = true },
              validate = { enable = true },
            },
          },
        },

        -- Terraform / HCL
        terraformls = {},

        -- Dockerfile
        dockerls = {},

        -- Docker Compose
        docker_compose_language_service = {},

        -- Ansible
        ansiblels = {
          settings = {
            ansible = {
              ansible     = { path = "ansible" },
              validation  = { enabled = true, lint = { enabled = true } },
              completion  = { provideRedirectModules = true, provideModuleOptionAliases = true },
              python      = { interpreterPath = "python3" },
            },
          },
          filetypes = { "yaml.ansible" },
        },

        -- Helm
        helm_ls = {
          settings = {
            ["helm-ls"] = {
              yamlls = {
                path    = "yaml-language-server",
                config  = {
                  schemas = {
                    kubernetes = "**",
                  },
                },
              },
            },
          },
        },
      }

      -- Setup each server
      local lspconfig = require("lspconfig")
      for server, config in pairs(servers) do
        config.capabilities = capabilities
        config.on_attach    = on_attach
        lspconfig[server].setup(config)
      end
    end,
  },

  -- ─── LSP progress indicator (spinner in bottom-right) ────────────────────
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts  = {
      notification = {
        window = { winblend = 0, border = "none" },
      },
    },
  },

  -- ─── Trouble: diagnostics list ───────────────────────────────────────────
  {
    "folke/trouble.nvim",
    cmd  = { "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",                         desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",            desc = "Buffer diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<CR>",                 desc = "Symbols (Trouble)" },
      { "<leader>cr", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>",  desc = "LSP references (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<CR>",                             desc = "Location list (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<CR>",                              desc = "Quickfix list (Trouble)" },
    },
  },
}
