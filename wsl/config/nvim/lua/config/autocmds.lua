-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local autocmd = vim.api.nvim_create_autocmd
-- Have line wrapping

autocmd("FileType", {
  -- Note that filetype.lua is used to determine file mappings
  pattern = { "markdown", "text", "typst" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- force LF on read/write (restrict to texty files to avoid surprises)
autocmd({ "BufReadPost", "BufWritePre" }, {
  pattern = { "*.lua", "*.typ", "*.md", "*.txt", "*.vim", "*.sh", "*.py" },
  command = "setlocal fileformat=unix",
})

-- stylua on save (guard if stylua missing)
do
  if vim.fn.executable("stylua") == 1 then
    local g = vim.api.nvim_create_augroup("LuaFormat", { clear = true })
    autocmd("BufWritePre", {
      group = g,
      pattern = "*.lua",
      callback = function()
        local v = vim.fn.winsaveview()
        vim.cmd([[silent %!stylua -]])
        vim.fn.winrestview(v)
      end,
    })
  end
end

-- 6) auto enter terminal mode
autocmd("TermOpen", {
  pattern = "*",
  command = "startinsert",
})
