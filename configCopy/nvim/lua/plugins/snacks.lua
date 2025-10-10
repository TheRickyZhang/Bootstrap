return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- This is already disabled in keymap.lua
    picker = {
      sources = {
        explorer = {
          win = {
            list = {
              keys = {
                ["<C-s>"] = function()
                  vim.cmd("wincmd l")
                end,
              },
            },
            input = {
              keys = {
                ["<C-s>"] = function()
                  vim.cmd("stopinsert")
                  vim.cmd("wincmd l")
                end,
              },
            },
          },
        },
      },
    },
    statuscolumn = { enabled = false }, -- Snacks draws the column
  },
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
