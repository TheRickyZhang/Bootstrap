-- TODO: Put all nvim-specific tools into mason (ex tinymist)
return {
  "williamboman/mason.nvim",
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
