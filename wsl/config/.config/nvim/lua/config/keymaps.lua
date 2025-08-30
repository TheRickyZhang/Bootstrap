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

-- Ctrl-Space → show blink.cmp completion
map("i", "<C-Space>", function()
  require("blink.cmp").show()
end, { silent = true })

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

-- <leader>p → Typst preview
map("n", "<leader>p", "<Cmd>TypstPreview<CR>", { silent = true })

-- compile current file -> same dir PDF (positional output, no -o)
map(
  "n",
  "<leader>te",
  "<Cmd>execute '!typst compile ' . shellescape(expand('%:p')) . ' ' . shellescape(expand('~/documents') . '/' . expand('%:t:r') . '.pdf')<CR>",
  { silent = true, desc = "Typst → ~/documents" }
)

-- map("n", "<leader>y", "Y$%", { silent = true })
map("n", "<leader>v", "V$%", { silent = true })

map("n", "<leader>ih", vim.lsp.buf.signature_help, { silent = true, desc = "Signature help" })
-- (Optional) <leader>g... → your Git commands
-- map("n","<leader>gs","<cmd>LazyGit<CR>",{silent=true})
-- map("n","<leader>gc","<cmd>Git commit<CR>",{silent=true})

-- <leader>d → delete into black hole
map({ "n", "v" }, "<leader>d", '"_d', { silent = true })

-- visual-mode p → paste without overwriting register
map("v", "p", '"_dP', { silent = true })

-- <leader>o → blank line below & above
map("n", "<leader>o", "o<Esc>O<Esc>", { silent = true })

-- *, # in visual → search for selection
map("v", "*", 'y/\\V<C-R>"<CR>', { silent = true })
map("v", "#", 'y?\\V<C-R>"<CR>', { silent = true })
