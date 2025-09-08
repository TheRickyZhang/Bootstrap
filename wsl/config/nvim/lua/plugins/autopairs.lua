-- plugins/autopairs.lua
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    local npairs = require("nvim-autopairs")
    local Rule = require("nvim-autopairs.rule")

    npairs.setup({})

    npairs.add_rules({
      Rule("$", "$", { "typst", "tex", "latex", "markdown" }):with_pair(function()
        return true
      end):with_move(function(opts)
        return opts.next_char == "$"
      end),
    })
  end,
}
