return {
  "folke/noice.nvim",
  opts = {
    routes = {
      {
        filter = {
          event = "lsp",
          find = "Validate documents",
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = "lsp", 
          find = "Publish Diagnostics",
        },
        opts = { skip = true },
      },
    },
  },
}
