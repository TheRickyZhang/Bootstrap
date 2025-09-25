-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- File mappings (if you need them)
-- vim.filetype.add({
--   extension = { typ = "typst" },
-- })

vim.g.autoformat = true

-- Get rid of annoying backup files
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.writebackup = true
vim.opt.backup = false

-- So that we aren't getting constant notifications
vim.lsp.handlers["textDocument/signatureHelp"] = function() end

-- We recognize both unix/windows line endings, but ALWAYS convert to unix on write for script consistency
vim.o.fileformats = "unix,dos"
-- Always save with LF, stripping any CR characters
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    vim.bo.fileformat = "unix"
    vim.cmd([[%s/\r$//e]])
  end,
})

vim.g.snacks_animate = false
