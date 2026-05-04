-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--rename-file-limit=100", -- Increase from default 50
          },
        },
        ["*"] = {
          keys = {
            {
              "gd",
              function()
                local word = vim.fn.expand("<cword>")
                if word:match("^vf_") then
                  -- grepprg is `rg --vimgrep` under LazyVim; rg uses Rust
                  -- regex (`(` is a group) and recurses by default.
                  vim.cmd('silent grep! "^[^/]*\\b' .. word .. '\\b\\s*\\(" -g "*.cpp" src/')
                  if #vim.fn.getqflist() == 1 then
                    vim.cmd("cfirst")
                    return
                  end
                end
                vim.lsp.buf.definition()
              end,
              desc = "Goto Definition (vf_-aware)",
              has = "definition",
            },
          },
        },
      },
    },
  },
}
