return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      tinymist = {
        root_dir = function(fname)
          local u = require("lspconfig.util")
          return u.root_pattern("typst.toml", ".git")(fname) or u.path.dirname(fname)
        end,
        settings = {
          projectResolution = "lockDatabase", -- improves cross-file defs
          -- formatterMode = "typstyle", exportPdf = "never",
        },
      },
    },
  },
}
