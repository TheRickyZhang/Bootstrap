-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.autoformat = true

-- We recognize both unix/windows line endings, but ALWAYS convert to unix on write for script consistency
vim.o.fileformats = "unix,dos"
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = "setlocal ff=unix",
})

vim.g.snacks_animate = false
