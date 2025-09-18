-- TODO: Put all nvim-specific tools into mason (ex tinymist)
return {
  "mason-org/mason.nvim",
  opts = {
    ensure_installed = {
      "tinymist",
      "stylua",
      "prettier",
      "shfmt",
      "luacheck",
    },
  },
}
