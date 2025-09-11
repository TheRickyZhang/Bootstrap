-- ~/.config/nvim/lua/config/keymaps.lua
local map = vim.keymap.set

-- Centering scroll & search
map("n", "<C-d>", "<C-d>zz", { silent = true })
map("n", "<C-u>", "<C-u>zz", { silent = true })
map("n", "n", "nzzzv", { silent = true })
map("n", "N", "Nzzzv", { silent = true })

local ok, api = pcall(require, "Comment.api")
if not ok then
  return
end

map("n", "<C-_>", api.toggle.linewise.current, { silent = true })
map("x", "<C-_>", function()
  api.toggle.linewise(vim.fn.visualmode())
end, { silent = true })

-- Legend: * = in chord, + = added custom to a chord, # = custom
------------------------------ Normal mode commands  ------------------------------
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
-- i  -
-- j  -
-- k  -
-- l  - lazy
-- m# - math in typst via $
-- n  - notifications             (May be overriden for math $$ in typst)
-- o  - show all in blink
-- p# - typst preview             (overwrites view yank history)
-- q  - nvim persistence          (TODO learn how to use this)
-- r  - primagen refactor         (TODO learn how to use this)
-- s* - search + various
-- t+ - (overwrites neotest, TODO not installed yet)
-- u  - toggle ui elements
-- v# - select matching
-- w  - lazy's wintow management
-- x  - help trouble (prepared when do make command, TODO see trouble.nvim)
-- y# - quick spell fix (z=1)
-- z# - Blink insertion suggestions

map("n", "<leader>gs", vim.lsp.buf.signature_help, {
  silent = true,
  desc = "Signature help",
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

map("n", "<leader>v", "V$%", { silent = true })

map("n", "<leader>y", "1z=")

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
-- n  - Backspace
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
-- y  - Insert the above character (Currently overriden by blink)
-- z  -

map("i", "<C-l>", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-k>", true, false, true), "n", false)
end, { desc = "Insert digraph" })

-- map("i", "<A-k>", function()
--   require("blink.cmp").show()
-- end, { silent = true })

-- Visual mode commands

map("v", "p", '"_dP', { silent = true })
map("v", "*", 'y/\\V<C-R>"<CR>', { silent = true })
map("v", "#", 'y?\\V<C-R>"<CR>', { silent = true })

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
