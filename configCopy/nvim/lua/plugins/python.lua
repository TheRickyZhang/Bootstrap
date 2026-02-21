-- lua/plugins/python.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        zuban = { enabled = false },
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic",
              },
            },
            python = {
              pythonPath = vim.fn.expand("~/.local/share/mise/shims/python"),
            },
          },
        },
      },
    },
  },
}
