return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        trigger = {
          -- Show sensibly, only on 2+ chars typed, ., -> with 200ms delay
          show_on_trigger_character = true,
          show_on_keyword = false,
          keyword_length = 2,
          throttle = 200,
        },
        menu = {
          auto_show = false,
        },
        -- LSP comes first, buffer only after 3 chars
        sources = {
          { name = "nvim_lsp", group_index = 1 },
          { name = "buffer", group_index = 2, keyword_length = 3 },
        },
      },
    },
  },
}
