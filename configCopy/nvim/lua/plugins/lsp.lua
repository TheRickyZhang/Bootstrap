-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--rename-file-limit=100", -- Increase from default 50
          },
        },
      },
    },
  },
}
