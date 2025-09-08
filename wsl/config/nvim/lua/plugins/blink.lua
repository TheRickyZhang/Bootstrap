return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        trigger = {
          show_on_trigger_character = true,
          show_on_keyword = false,
        },
        menu = { auto_show = false },
      },
      sources = {
        -- order is by provider score; this enables LSP then buffer
        default = { "lsp", "buffer" },
        providers = {
          lsp = { min_keyword_length = 2 }, -- “2+ chars” for LSP
          buffer = { min_keyword_length = 3 }, -- buffer only after 3 chars
          -- tweak priority if desired: score_offset = +/-N
          -- fallbacks = {...} also available
        },
      },
    },
  },
}
