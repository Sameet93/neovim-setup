-- ============================================================================
-- AI: CodeCompanion — local-first AI assistant powered by Ollama
--
-- Default adapter: Ollama (fully local, no data leaves your machine)
-- Recommended model: codestral (Mistral AI, 22B, excellent at HCL/Terraform)
--
-- Prerequisites:
--   brew install ollama
--   ollama pull codestral
--   ollama serve          (or: brew services start ollama)
--
-- Switch models at any time: :CodeCompanionModels
-- ============================================================================

return {
  {
    "olimorris/codecompanion.nvim",
    version      = false,
    event        = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Render markdown in the chat buffer (code blocks, headers, etc.)
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion" },
        opts = {},
      },
    },
    keys = {
      -- Chat
      { "<leader>ac",  "<cmd>CodeCompanionChat Toggle<CR>",   mode = { "n", "v" }, desc = "AI: toggle chat" },
      { "<leader>an",  "<cmd>CodeCompanionChat<CR>",           mode = { "n", "v" }, desc = "AI: new chat" },
      -- Inline actions
      { "<leader>ai",  "<cmd>CodeCompanion<CR>",               mode = { "n", "v" }, desc = "AI: inline prompt" },
      { "<leader>aa",  "<cmd>CodeCompanionActions<CR>",        mode = { "n", "v" }, desc = "AI: action picker" },
      -- Quick shortcuts (visual mode — act on selection)
      { "<leader>ae",  "<cmd>CodeCompanion /explain<CR>",      mode = "v",          desc = "AI: explain selection" },
      { "<leader>af",  "<cmd>CodeCompanion /fix<CR>",          mode = "v",          desc = "AI: fix selection" },
      { "<leader>at",  "<cmd>CodeCompanion /tests<CR>",        mode = "v",          desc = "AI: generate tests" },
      { "<leader>ar",  "<cmd>CodeCompanion /review<CR>",       mode = "v",          desc = "AI: review code" },
      { "<leader>am",  "<cmd>CodeCompanion /commit<CR>",       mode = "n",          desc = "AI: generate commit msg" },
    },
    opts = {
      -- ── Adapters ────────────────────────────────────────────────────────
      -- NOTE: v19+ nests http adapters under adapters.http.*
      adapters = {
        http = {
          -- Local Ollama adapter — fully private, no network required
          ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
              schema = {
                model = {
                  default = "codestral",  -- change to e.g. "llama3.1:8b" if low RAM
                },
                num_ctx = {
                  default = 16384,  -- context window (tokens); reduce if OOM
                },
                temperature = {
                  default = 0.1,    -- low temp = more deterministic (good for code)
                },
              },
            })
          end,
        },
      },

      -- ── Interactions (which adapter each mode uses) ──────────────────────
      -- NOTE: v19+ renamed "strategies" to "interactions"
      interactions = {
        chat = {
          adapter = "ollama",
          -- <C-CR> in insert mode sends the message (more intuitive than <C-s>).
          -- Normal-mode <CR> / <C-s> are preserved from the defaults.
          keymaps = {
            send = {
              modes    = { n = { "<CR>", "<C-s>" }, i = { "<C-s>", "<C-CR>" } },
              index    = 2,
              callback = "keymaps.send",
              description = "[Request] Send response",
            },
          },
          -- Override slash_commands to prefer telescope as the picker
          slash_commands = {
            ["file"] = {
              path = "interactions.chat.slash_commands.builtin.file",
              opts = { provider = "telescope" },
            },
            ["buffer"] = {
              path = "interactions.chat.slash_commands.builtin.buffer",
              opts = { provider = "telescope" },
            },
          },
          -- System prompt tailored for DevOps / infrastructure work
          opts = {
            system_prompt = function(_)
              return [[You are an expert DevOps and infrastructure engineer assistant
embedded in Neovim. You specialise in:
- Terraform / OpenTofu HCL — modules, providers, state management, best practices
- Ansible — playbooks, roles, Jinja2 templates, inventory management
- Kubernetes & Helm — manifests, charts, values, RBAC, networking
- Docker & container best practices
- Bash / shell scripting — POSIX-compatible, robust error handling
- Go and Python development
- CI/CD pipelines (GitHub Actions, GitLab CI, ArgoCD)

When writing code:
- Prefer explicit, readable code over clever one-liners
- Always include error handling
- Follow the principle of least privilege for IAM/RBAC definitions
- For Terraform: use consistent naming, tag all resources, avoid hardcoded values
- For Ansible: use roles, avoid shell/command modules when a module exists
- Keep responses concise unless asked to elaborate

You have access to the user's current file and any context they share.]]
            end,
          },
        },
        inline = { adapter = "ollama" },
        cmd    = { adapter = "ollama" },
      },

      -- ── Display ──────────────────────────────────────────────────────────
      display = {
        action_palette = {
          provider = "telescope",  -- uses telescope for action picker
        },
        chat = {
          window = {
            layout   = "vertical",  -- "vertical" | "horizontal" | "float"
            width    = 0.35,        -- 35% of the screen width
            position = "right",
          },
          show_settings    = false,
          show_token_count = true,
          render_headers   = true,
        },
      },
    },

    config = function(_, opts)
      require("codecompanion").setup(opts)

      -- Notify if Ollama is not running when the plugin loads
      vim.defer_fn(function()
        local handle = io.popen("curl -s --max-time 2 http://localhost:11434/api/tags 2>/dev/null")
        if handle then
          local result = handle:read("*a")
          handle:close()
          if result == "" then
            vim.notify(
              "Ollama is not running.\nStart it with: ollama serve\nor: brew services start ollama",
              vim.log.levels.WARN,
              { title = "CodeCompanion" }
            )
          end
        end
      end, 3000)
    end,
  },

  -- ─────────────────────────────────────────────────────────────────────────
  -- Inline AI completion: Copilot-style ghost text via Ollama
  -- Suggestions appear while you type (after a short idle delay).
  --
  -- Accept keymaps:
  --   <A-a>  — accept the whole suggestion
  --   <A-l>  — accept one line
  --   <A-e>  — dismiss
  --   <A-]>  — cycle to next suggestion   <A-[>  — cycle to prev
  -- ─────────────────────────────────────────────────────────────────────────
  {
    "milanglacier/minuet-ai.nvim",
    event        = "InsertEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("minuet").setup({
        -- Use Ollama via its OpenAI-compatible endpoint
        provider = "openai_compatible",
        provider_options = {
          openai_compatible = {
            model     = "codestral",
            api_key   = "TERM",  -- Ollama needs no key; "TERM" env var is always set
            end_point = "http://localhost:11434/v1/chat/completions",  -- full URL
            name      = "Ollama",
            stream    = true,
            optional  = {
              max_tokens = 256,
              top_p      = 0.9,
            },
          },
        },
        n_completions  = 1,       -- one suggestion at a time keeps it snappy
        context_window = 6144,    -- tokens of surrounding code to send
        delay_ms       = 1000,    -- wait 1 s idle before requesting (avoids spam)
        -- Virtual (ghost) text — appears inline, like Copilot
        virtualtext = {
          auto_trigger_ft = { "*" },   -- trigger on all filetypes
          -- Don't trigger inside special/non-code buffers
          auto_trigger_ignore_ft = {
            "codecompanion", "TelescopePrompt", "neo-tree",
            "NvimTree", "help", "lazy", "mason",
          },
          keymap = {
            accept      = "<A-a>",  -- accept full suggestion
            accept_line = "<A-l>",  -- accept one line
            next        = "<A-]>",  -- next suggestion
            prev        = "<A-[>",  -- prev suggestion
            dismiss     = "<A-e>",  -- dismiss
          },
        },
      })
    end,
  },
}
