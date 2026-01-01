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

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.typ",
  callback = function()
    vim.opt_local.filetype = "typst"
  end,
})

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
--
-- :Align {delim}  (range required)
vim.api.nvim_create_user_command("Align", function(o)
  local d = o.args
  if d == "" or o.range == 0 then
    return
  end
  local s, e = o.line1 - 1, o.line2
  local ls = vim.api.nvim_buf_get_lines(0, s, e, false)

  local m, pos = 0, {}
  for i, L in ipairs(ls) do
    local a = L:find(d, 1, true)
    if a then
      local w = vim.fn.strdisplaywidth(L:sub(1, a - 1))
      if w > m then
        m = w
      end
      pos[i] = { a, w }
    end
  end
  if m == 0 then
    return
  end

  for i, p in pairs(pos) do
    local a, w = p[1], p[2]
    local L = ls[i]
    ls[i] = L:sub(1, a - 1) .. string.rep(" ", m - w) .. L:sub(a)
  end
  vim.api.nvim_buf_set_lines(0, s, e, false, ls)
end, { nargs = 1, range = true })


-- Automatically set makeprg, so :make | copen populates the quick fix list with failing files
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  callback = function(ev)
    local ok, lazyvim = pcall(require, "lazyvim.util")
    if not ok then return end

    local root = lazyvim.root()
    if not root or root == "" then return end

    local build = root .. "/build"
    if vim.fn.isdirectory(build) == 0 then return end

    -- buffer-local makeprg (so different projects can differ)
    vim.bo[ev.buf].makeprg = ("cmake --build %s --parallel 8"):format(vim.fn.shellescape(build))
  end,
})
