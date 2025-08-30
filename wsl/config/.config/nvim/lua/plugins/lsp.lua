-- ~/.config/nvim/lua/plugins/lsp.lua
-- Use leader ih for toggling on inlay hints
return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
      ["*"] = function(_, s)
        local orig = s.on_attach
        s.on_attach = function(client, bufnr)
          if orig then
            orig(client, bufnr)
          end
          vim.keymap.set(
            "n",
            "<leader>ih",
            vim.lsp.buf.signature_help,
            { buffer = bufnr, silent = true, desc = "Signature help" }
          )
        end
      end,
    },
  },
}
