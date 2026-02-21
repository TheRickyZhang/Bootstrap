-- lua/plugins/treesitter-context.lua
return {
  "nvim-treesitter/nvim-treesitter-context",
  opts = {
    enable = false,  -- off by default
    max_lines = 6,
    multiline_threshold = 1,  -- truncate long signatures to 1 line each for easier distinction
  },
  keys = {
    { "<leader>ct", "<cmd>TSContext toggle<cr>", desc = "Toggle Treesitter Context" },
  },
}
