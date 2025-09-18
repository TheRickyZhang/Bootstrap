-- Only for typst buffers
local map = vim.keymap.set

map("n", "<leader>y", "gsaiW$", { remap = true, buffer = true })
map("x", "<leader>y", "gsa$", { remap = true, buffer = true })

map("i", "<C-y>", function()
  local keys = vim.api.nvim_replace_termcodes("<Esc><leader>yA", true, false, true)
  vim.api.nvim_feedkeys(keys, "m", false)
end, { buffer = true })
