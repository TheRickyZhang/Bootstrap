return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
  enabled = function(root_dir)
    -- vim.notify("lazydev root: " .. root_dir .. " luarc: " .. tostring(vim.uv.fs_stat(root_dir .. "/.luarc.json") ~= nil))
    return not vim.uv.fs_stat(root_dir .. "/.luarc.json")
  end
  },
}
