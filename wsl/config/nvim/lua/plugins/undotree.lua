return {
  {
    "mbbill/undotree",
    config = function()
      vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>", {
        silent = true,
        desc = "UndoTree",
      })
      vim.opt.undofile = true
      vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"
    end,
  },
}
