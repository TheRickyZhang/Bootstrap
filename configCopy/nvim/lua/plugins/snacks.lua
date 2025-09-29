return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    picker = { enabled = true },
    statuscolumn = { enabled = false }, -- Snacks draws the column
    -- statuscolumn = { enabled = true }, -- Snacks draws the column
    -- icons = { -- set fold glyphs Snacks uses
    --   fold = { open = "▾", close = "▸", sep = "│" },
    -- },
  }, -- your snacks opts
  keys = {
    {
      "<leader>ft",
      function()
        Snacks.picker.files()
      end,
      desc = "Files",
    },
  },
}
