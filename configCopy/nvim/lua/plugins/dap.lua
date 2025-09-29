return {
  -- base DAP; configure codelldb here
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>dn",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle BP",
      },
    },
    config = function()
      local dap = require("dap")
      local codelldb = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = { command = codelldb, args = { "--port", "${port}" } },
      }
      dap.configurations.cpp = {
        {
          name = "codelldb",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":r")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = true,
          console = "integratedTerminal",
        },
      }
      dap.configurations.c = dap.configurations.cpp
    end,
  },
  -- optional: make Mason install the adapter
  { "jay-babu/mason-nvim-dap.nvim", opts = { ensure_installed = { "codelldb" } } },
}
