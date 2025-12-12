return {
  { "hrsh7th/nvim-cmp", enabled = false },
  {
    "saghen/blink.cmp",
    opts = { -- keep your existing opts
      completion = {
        trigger = {
          show_on_trigger_character = true,
          -- show_on_keyword = false,
          show_on_keyword = true,
        },
        menu = {
          auto_show = true,
          -- auto_show = function()
          --   return vim.g.blink_auto
          -- end,
        },
      },
      sources = {
        default = { "lsp", "buffer" },
      },
      keymap = {
        ["<C-y>"] = { "accept" },
        -- Important so that enter key does NOT trigger completion, by default it is Ctrl-y
        ["<CR>"] = { "fallback" },
        ["<C-e>"] = { "fallback" },
      },
    },
  },
}
