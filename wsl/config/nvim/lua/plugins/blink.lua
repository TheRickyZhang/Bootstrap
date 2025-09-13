return {
  {
    "saghen/blink.cmp",
    opts = { -- keep your existing opts
      completion = {
        trigger = {
          show_on_trigger_character = true,
          -- show_on_keyword = false,
        },
        menu = { auto_show = false },
      },
      sources = {
        default = { "lsp", "buffer" },
        providers = {
          lsp = { min_keyword_length = 2 },
          buffer = { min_keyword_length = 3 },
        },
      },
    },
  },
}
