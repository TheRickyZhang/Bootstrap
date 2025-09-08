-- ~/.config/nvim/lua/config/keymaps.lua
local map = vim.keymap.set

-- Centering scroll & search
map("n", "<C-d>", "<C-d>zz", { silent = true })
map("n", "<C-u>", "<C-u>zz", { silent = true })
map("n", "n", "nzzzv", { silent = true })
map("n", "N", "Nzzzv", { silent = true })

-- Ctrl-/ → toggle comment (Comment.nvim must be installed)
local ok, comment = pcall(require, "Comment.api")
if ok then
  for _, mode in ipairs({ "n", "v" }) do
    map(mode, "<C-_>", function()
      if mode == "n" then
        comment.toggle.linewise.current()
      else
        comment.toggle.linewise(vim.fn.visualmode())
      end
    end, { silent = true })
  end
end

-- Alt-j/k → move lines up/down
map("n", "<A-j>", ":m .+1<CR>==", { silent = true })
map("n", "<A-k>", ":m .-2<CR>==", { silent = true })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true })

local motions = {
  ["<A-w>"] = "/\\u<CR>", -- next Uppercase
  ["<A-b>"] = "?\\u<CR>", -- prev Uppercase
  ["<A-e>"] = "/\\u<CR>h", -- end of camel-part
  ["<A-g>e"] = "?\\u<CR>l", -- “ge”: Alt-g then e
}

for lhs, rhs in pairs(motions) do
  for _, mode in ipairs({ "n", "o", "x" }) do
    map(mode, lhs, rhs, { silent = true, noremap = true })
  end
end

-- Insert mode commands
map("n", "<leader>gs", vim.lsp.buf.signature_help, {
  silent = true,
  desc = "Signature help",
})

map("i", "<C-g>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-k>", true, false, true), "n", false)
end, { desc = "Insert digraph" })

map("i", "<C-i>", function()
  local keys = vim.api.nvim_replace_termcodes("<Esc><leader>iA", true, false, true)
  vim.api.nvim_feedkeys(keys, "m", false) -- "m" = allow remap
end)

map("i", "<A-k>", function()
  require("blink.cmp").show()
end, { silent = true })

-- Letter status for leader (* = prefix for other things already in lazy, # = self defined, + = adding to existing prefix)
-- Ctrl - tmux
-- a  - copilot
-- b* - buffer
-- c* - various
-- d* - debugging
-- e  - explorer
-- f* - snacks find
-- g+ - git
-- h  - harpoon
-- i# - math with typst
-- j  -
-- k  -
-- l  - lazy
-- m# - math in typst via $
-- n  - notifications
-- o  - show all in blink
-- p# - typst preview (overwrites view yank history)
-- q  - nvim persistence (TODO learn how to use this)
-- r  - primagen refactor (TODO learn how to use this)
-- s* - search + various
-- t+ - (overwrites neotest, TODO not installed yet)
-- u  - toggle ui elements
-- v# - select matching
-- w  - lazy's wintow management
-- x  - help trouble (prepared when do make command, TODO see trouble.nvim)
-- y# - quick spell fix (z=1)
-- z# - Blink insertion suggestions

-- Insert mode mappings that are not available: c, d, g(digraphs), h, i, j, k, m, n, p, r, s (remapped to signature), t,  w
--

-- Add math mode for typst with surrounding $
map("n", "<leader>i", "gsaiW$", {
  remap = true,
})

map("n", "<leader>k", function()
  vim.cmd("startinsert")
  require("blink.cmp").show()
end, { silent = true, desc = "Trigger completion from normal mode" })

map("n", "<leader>p", "<Cmd>TypstPreview<CR>", { silent = true })

-- compile current file -> same dir PDF (positional output, no -o)
map(
  "n",
  "<leader>th",
  "<Cmd>execute '!typst compile ' . shellescape(expand('%:p')) . ' ' . shellescape(expand('~/documents') . '/' . expand('%:t:r') . '.pdf')<CR>",
  { silent = true, desc = "Typst → ~/documents" }
)
map(
  "n",
  "<leader>tc",
  "<Cmd>execute '!typst compile ' . shellescape(expand('%:p')) . ' ' . shellescape(expand('%:p:h') . '/' . expand('%:t:r') . '.pdf')<CR>",
  { silent = true, desc = "Typst → same dir" }
)

-- map("n", "<leader>y", "Y$%", { silent = true })
map("n", "<leader>v", "V$%", { silent = true })

map("n", "<leader>y", "1z=")

-- <leader>d → delete into black hole
-- map({ "n", "v" }, "<leader>d", '"_d', { silent = true })

-- Visual mode commands

map("v", "p", '"_dP', { silent = true })
map("v", "*", 'y/\\V<C-R>"<CR>', { silent = true })
map("v", "#", 'y?\\V<C-R>"<CR>', { silent = true })
