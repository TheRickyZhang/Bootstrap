-- Only for typst buffers
local map = vim.keymap.set

map("n", "<leader>n", "gsaiW$", { remap = true, buffer = true })

map("i", "<C-n>", function()
  local keys = vim.api.nvim_replace_termcodes("<Esc><leader>nA", true, false, true)
  vim.api.nvim_feedkeys(keys, "m", false)
end, { buffer = true })
