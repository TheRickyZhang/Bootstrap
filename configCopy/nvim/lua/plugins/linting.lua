-- lua/plugins/linting.lua
return {
  "mfussenegger/nvim-lint",
  opts = function(_, opts)
    local linter = require("lint").linters["markdownlint-cli2"]
    linter.args = vim.list_extend(
      { "--config", vim.fn.expand("~/.markdownlint.json") },
      linter.args or {}
    )
  end,
}
