-- ~/.config/nvim/lua/config/keymaps.lua
local map = vim.keymap.set

-- Centering scroll & search
map("n", "<C-d>", "<C-d>zz", { silent = true })
map("n", "<C-u>", "<C-u>zz", { silent = true })
map("n", "n", "nzzzv", { silent = true })
map("n", "N", "Nzzzv", { silent = true })

-- More convenient mappings for single toggling (keep usage of gco, gcO)
map("n", "g/", "gcc", { remap = true, silent = true })
map("x", "g/", "gc", { remap = true, silent = true })

-- Buffer management
map("n", "<C-j>", "<cmd>bprevious<cr>", { desc = "Buffer ← (previous)" })
map("n", "<C-k>", "<cmd>bnext<cr>", { desc = "Buffer → (next)" })
map("n", "<C-x>", "<cmd>bdelete<cr>", { desc = "Buffer close" })

-- Window management
map({ "n", "t" }, "<C-s>", [[<C-\><C-n><Cmd>wincmd w<CR>]], { desc = "Next window", silent = true })

-- Invoke Blink completion manually
map("n", "<C-n>", function()
  vim.cmd("startinsert")
  require("blink.cmp").show()
end, { silent = true })

map("i", "<C-n>", function()
  require("blink.cmp").show()
end, { silent = true })

-- You can find all default neovim bindings with :help index

-- Legend: * = in chord, + = added custom to a chord, # = custom
------------------------------ Normal mode leader commands  ------------------------------
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
-- i  - new buffer
-- j  -
-- k  -
-- l  - lazy
-- m# - math typst syntax
-- n  - notifications             (May be overriden for math $$ in typst)
-- o  - show all in blink
-- p# - typst preview             (overwrites view yank history)
-- q  - nvim persistence          (TODO learn how to use this)
-- r  - primagen refactor         (TODO learn how to use this)
-- s* - search + various
-- t+ - (overwrites neotest, TODO not installed yet)
-- u  - toggle ui elements
-- v# - select matching
-- W  - lazy's wintow management
-- x  - help trouble (prepared when do make command, TODO see trouble.nvim)
-- y# - math in typst via $
-- z# - quick spell fix (z=1)

map("n", "<leader>gs", vim.lsp.buf.signature_help, {
  silent = true,
  desc = "Signature help",
})

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

map("n", "<leader>v", "V$%", { silent = true })

-- For easier file yanking
map("n", "<leader>yp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "yank abs path" })
map("n", "<leader>yr", function()
  vim.fn.setreg("+", vim.fn.expand("%"))
end, { desc = "yank relative path" })
map("n", "<leader>yf", function()
  vim.fn.setreg("+", vim.fn.expand("%:t"))
end, { desc = "yank filename" })
map("n", "<leader>yd", function()
  vim.fn.setreg("+", vim.fn.expand("%:h"))
end, { desc = "yank dir" })

map("n", "<leader>z", "1z=")
-- <leader>d → delete into black hole
-- map({ "n", "v" }, "<leader>d", '"_d', { silent = true })

------------------------------ Insert mode commands  ------------------------------
-- Insert Mode Mappings
-- a  - text insertion
-- b  -
-- c  - Esc
-- d  - deindent
-- e  - Insert below character
-- f  - snacks find
-- g  - Override current file summary
-- h  - Backspace
-- i  - Tab
-- j  - Enter
-- k  - Signature help (Override digraph)
-- l+ - literal digraph
-- m  - Enter
-- n+ - Auto complete (overridden to Blink LSP complete)
-- o  - One normal mode
-- p? - Backwards keyword completion?
-- q  - Insert literal ^X
-- r  - Register
-- s  - Save
-- t+ - Tab
-- u  - Delete to line begin
-- v# - Paste
-- w  - Delete word back
-- x  - Super special mode for niche things?
-- y  - Insert the above character (overridden to math)
-- z  -

map("i", "<C-l>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-k>", true, false, true), "n", false)
end, { desc = "Insert digraph" })

-- map("i", "<A-k>", function()
--   require("blink.cmp").show()
-- end, { silent = true })

-- Visual mode commands
-- Same as normal: a, b, c, d, e, f, g, h, i, j, k, l, m, n?, p, q, r, s, t, u, v, w, x, y
-- o
-- z (fold plugin, one option)

map("v", "p", '"_dP', { silent = true })
map("v", "*", 'y/\\V<C-R>"<CR>', { silent = true })
map("v", "#", 'y?\\V<C-R>"<CR>', { silent = true })

vim.keymap.set("x", "ga", function()
  local v = vim.fn.getpos("v")[2]
  local c = vim.fn.getpos(".")[2]
  if v == 0 or c == 0 then
    return
  end
  if v > c then
    v, c = c, v
  end
  local ch = vim.fn.getcharstr()
  if ch == "" then
    return
  end
  vim.cmd(("%d,%dAlign %s"):format(v, c, ch))
end, { silent = true, desc = "Align by next char" })

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
