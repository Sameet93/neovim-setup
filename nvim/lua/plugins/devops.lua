-- ============================================================================
-- DevOps: Ansible detection, Jinja2 syntax, Python venv, and DAP debugging
-- ============================================================================

return {

  -- ─── Helm: filetype detection for templates/ files ───────────────────────
  -- Ensures .yaml/.yml/.tpl files inside a Helm chart's templates/ directory
  -- are detected as "helm" instead of "yaml", so yamllint is not invoked.
  {
    dir = vim.fn.stdpath("config"),  -- no plugin to install, just config
    name = "helm-filetype-detect",
    lazy = false,
    config = function()
      vim.filetype.add({
        pattern = {
          -- Match *.yaml / *.yml / *.tpl under any templates/ directory;
          -- confirm a Chart.yaml exists somewhere up the tree.
          [".*/templates/.*%.ya?ml"] = function(path)
            local dir = vim.fn.fnamemodify(path, ":h")
            while dir ~= "/" and dir ~= "." do
              if vim.fn.filereadable(dir .. "/Chart.yaml") == 1 then
                return "helm"
              end
              local parent = vim.fn.fnamemodify(dir, ":h")
              if parent == dir then break end
              dir = parent
            end
          end,
          [".*/templates/.*%.tpl"] = function(path)
            local dir = vim.fn.fnamemodify(path, ":h")
            while dir ~= "/" and dir ~= "." do
              if vim.fn.filereadable(dir .. "/Chart.yaml") == 1 then
                return "helm"
              end
              local parent = vim.fn.fnamemodify(dir, ":h")
              if parent == dir then break end
              dir = parent
            end
          end,
        },
      })
    end,
  },

  -- ─── Ansible: filetype detection + improved syntax ───────────────────────
  -- Detects Ansible playbooks/roles/tasks as "yaml.ansible" filetype so
  -- ansible-language-server (ansiblels) and ansiblelint activate correctly.
  {
    "pearofducks/ansible-vim",
    ft = { "yaml.ansible", "yaml", "yml" },
    init = function()
      -- Paths that are always treated as Ansible YAML
      vim.g.ansible_ftdetect_filename_regex =
        [[\v(playbook|site|main|local|requirements)\.ya?ml$]]
      -- Ansible role directory patterns (tasks/, handlers/, defaults/, vars/, etc.)
      vim.g.ansible_unindent_after_newline = 1
      vim.g.ansible_attribute_highlight    = "ob"
      vim.g.ansible_name_highlight         = "b"
      vim.g.ansible_extra_keywords_highlight = 1
    end,
  },

  -- ─── Jinja2 syntax (Ansible templates use Jinja2 heavily) ────────────────
  -- Covers *.j2 / *.jinja / *.jinja2 files used in Ansible template tasks.
  {
    "Glench/Vim-Jinja2-Syntax",
    ft = { "jinja", "jinja2", "j2", "htmljinja" },
    init = function()
      -- Associate common Ansible template extensions with jinja2 filetype
      vim.filetype.add({
        extension = {
          j2     = "jinja2",
          jinja  = "jinja2",
          jinja2 = "jinja2",
        },
      })
    end,
  },

  -- ─── Python virtual-environment selector ─────────────────────────────────
  -- <leader>pv opens a Telescope picker to activate a venv from standard
  -- locations (.venv, venv, ~/.virtualenvs, pyenv, Conda, Poetry, Pipenv…).
  -- Automatically updates pyright / pylsp / ruff to use the chosen env.
  {
    "linux-cultist/venv-selector.nvim",
    branch       = "regexp",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
    ft  = "python",
    cmd = "VenvSelect",
    keys = {
      { "<leader>pv", "<cmd>VenvSelect<CR>",        desc = "Select virtual env" },
      { "<leader>pV", "<cmd>VenvSelectCached<CR>",  desc = "Re-use last virtual env" },
    },
    opts = {
      settings = {
        options = {
          notify_user_on_venv_activation = true,
        },
      },
    },
  },

  -- ─── Database UI: vim-dadbod + vim-dadbod-ui ────────────────────────────
  -- Provides a stable database drawer plus SQL query execution from buffers.
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    keys = {
      { "<leader>od", "<cmd>DBUIToggle<CR>", desc = "Open database UI" },
      { "<leader>oa", "<cmd>DBUIAddConnection<CR>", desc = "Add database connection" },
      { "<leader>of", "<cmd>DBUIFindBuffer<CR>", desc = "Find database buffer" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"
    end,
  },

  -- ─── DAP: Debug Adapter Protocol core ────────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- DAP UI (variables, call-stack, breakpoints, console panes)
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        keys = {
          { "<leader>du", function() require("dapui").toggle({}) end, desc = "DAP UI toggle" },
          { "<leader>de", function() require("dapui").eval()     end, desc = "DAP eval expression", mode = { "n", "v" } },
        },
        config = function()
          local dapui = require("dapui")
          dapui.setup({
            icons = { expanded = "", collapsed = "", current_frame = "" },
            layouts = {
              {
                elements = {
                  { id = "scopes",      size = 0.35 },
                  { id = "breakpoints", size = 0.20 },
                  { id = "stacks",      size = 0.25 },
                  { id = "watches",     size = 0.20 },
                },
                size    = 40,
                position = "left",
              },
              {
                elements = {
                  { id = "repl",    size = 0.5 },
                  { id = "console", size = 0.5 },
                },
                size     = 12,
                position = "bottom",
              },
            },
          })
          -- Auto-open/close UI when debugging starts/stops
          local dap = require("dap")
          dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open({})  end
          dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close({}) end
          dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close({}) end
        end,
      },

      -- Inline variable values while debugging
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = { commented = true },
      },

      -- Python debug adapter (uses debugpy installed via Mason)
      {
        "mfussenegger/nvim-dap-python",
        keys = {
          { "<leader>dpm", function() require("dap-python").test_method() end, desc = "DAP: test method",  ft = "python" },
          { "<leader>dpc", function() require("dap-python").test_class()  end, desc = "DAP: test class",   ft = "python" },
          { "<leader>dps", function() require("dap-python").debug_selection() end, mode = "v", desc = "DAP: debug selection", ft = "python" },
        },
        config = function()
          -- Point at the debugpy installed by Mason
          local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
          require("dap-python").setup(mason_path)
        end,
      },
    },

    keys = {
      { "<leader>db",  function() require("dap").toggle_breakpoint()                end, desc = "DAP toggle breakpoint" },
      { "<leader>dB",  function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "DAP conditional breakpoint" },
      { "<leader>dc",  function() require("dap").continue()                         end, desc = "DAP continue" },
      { "<leader>di",  function() require("dap").step_into()                        end, desc = "DAP step into" },
      { "<leader>dn",  function() require("dap").step_over()                        end, desc = "DAP step over" },
      { "<leader>do",  function() require("dap").step_out()                         end, desc = "DAP step out" },
      { "<leader>dr",  function() require("dap").repl.toggle()                      end, desc = "DAP toggle REPL" },
      { "<leader>dl",  function() require("dap").run_last()                         end, desc = "DAP run last" },
      { "<leader>dx",  function() require("dap").terminate()                        end, desc = "DAP terminate" },
      { "<leader>dL",  function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log message: ")) end, desc = "DAP log point" },
    },

    config = function()
      -- DAP sign icons
      vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpoint",         linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint",            { text = "◎", texthl = "DapLogPoint",            linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStopped",             linehl = "DapStopped", numhl = "DapStopped" })
      vim.fn.sign_define("DapBreakpointRejected",  { text = "○", texthl = "DapBreakpointRejected",  linehl = "", numhl = "" })
    end,
  },
}
