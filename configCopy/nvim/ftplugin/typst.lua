-- Only for typst buffers
local map = vim.keymap.set

map("n", "<leader>m", "gsaiW$", { remap = true, buffer = true })
map("n", "<C-m>", "gsaiW$", { remap = true, buffer = true })

map("x", "<leader>m", "gsa$", { remap = true, buffer = true })
map("x", "<C-m>", "gsa$", { remap = true, buffer = true })

map("i", "<C-e>", function()
  local keys = vim.api.nvim_replace_termcodes("<Esc><C-m>Ea", true, false, true)
  vim.api.nvim_feedkeys(keys, "m", false)
end, { buffer = true })
