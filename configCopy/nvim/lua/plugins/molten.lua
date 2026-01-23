return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_image_provider = "none"
      vim.g.molten_output_win_max_height = 20
    end,
    keys = {
      { "<leader>mi", "<cmd>MoltenInit<cr>", desc = "Init kernel" },
      { "<leader>ml", "<cmd>MoltenEvaluateLine<cr>", desc = "Eval line" },
      { "<leader>mv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Eval visual" },
      { "<leader>mo", "<cmd>MoltenShowOutput<cr>", desc = "Show output" },
    },
  },
  { "GCBallesteros/jupytext.nvim", config = true },
}
