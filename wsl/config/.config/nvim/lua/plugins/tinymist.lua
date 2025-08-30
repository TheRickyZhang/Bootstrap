-- ~/.config/nvim/lua/plugins/tinymist.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local util = require("lspconfig.util")
      opts.servers = opts.servers or {}
      opts.servers.tinymist = {
        cmd = { "tinymist" },
        filetypes = { "typst" },
        settings = { formatterMode = "typstyle" },
        root_dir = util.root_pattern(".git"),
      }

      -- add buffer-local :ExportSvg/:ExportPdf/... without clobbering LazyVim's on_attach
      opts.setup = opts.setup or {}
      opts.setup.tinymist = function(_, server_opts)
        local orig = server_opts.on_attach
        server_opts.on_attach = function(client, bufnr)
          if orig then
            orig(client, bufnr)
          end

          local function mk(cmd)
            local k = cmd:match("tinymist%.export(%w+)")
            vim.api.nvim_buf_create_user_command(bufnr, "Export" .. k, function()
              client.request("workspace/executeCommand", {
                command = cmd,
                arguments = { vim.api.nvim_buf_get_name(bufnr) },
              }, nil, bufnr)
            end, { desc = "Export to " .. k })
          end

          for _, c in ipairs({
            "tinymist.exportSvg",
            "tinymist.exportPng",
            "tinymist.exportPdf",
            "tinymist.exportHtml",
            "tinymist.exportMarkdown",
          }) do
            mk(c)
          end
        end

        require("lspconfig").tinymist.setup(server_opts)
        return true -- tell LazyVim we handled setup
      end
    end,
  },
}
