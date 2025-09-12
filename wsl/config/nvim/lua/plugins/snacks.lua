return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = { picker = { enabled = true } }, -- your snacks opts
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
