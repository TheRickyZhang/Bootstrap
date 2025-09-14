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
    -- Rebind C-/ since it is used for commenting
    -- { "<C-/>", false },
    -- { "<C-_>", false },
    -- {
    --   "<C-`>",
    --   function()
    --     Snacks.terminal()
    --   end,
    --   mode = { "n", "t" },
    --   desc = "Toggle Terminal",
    -- },
  },
}
