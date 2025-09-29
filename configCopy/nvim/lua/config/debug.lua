local map = vim.keymap.set
local fe = vim.fn.fnameescape
local fp = function()
  return vim.fn.expand("%:p")
end

vim.g.autoformat = false

-- 1) CodeLLDB adapter
local dap = require("dap")
local codelldb = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = { command = codelldb, args = { "--port", "${port}" } },
}

-- 2) Make DAP use an actual terminal split for program I/O
dap.defaults.fallback.terminal_win_cmd = function()
  vim.cmd("belowright 12split | enew")
  return vim.api.nvim_get_current_buf()
end
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "dap-terminal*",
  callback = function()
    vim.cmd("startinsert")
  end,
})
dap.listeners.after.event_initialized.focus_dap_term = function()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(b):match("dap%-terminal") then
      local w = (vim.fn.getbufinfo(b)[1] or {}).windows
      if w and #w > 0 then
        vim.api.nvim_set_current_win(w[1])
        vim.cmd("startinsert")
      end
      break
    end
  end
end

-- 3) Run current file (no debug), stdin in terminal
map("n", "<leader>r", function()
  vim.cmd("update | botright split")
  vim.cmd("terminal bash -lc " .. vim.fn.shellescape("./run.sh " .. fe(fp())))
  vim.cmd("startinsert")
end, { desc = "run current file" })

-- 4) Build with debug flags, then debug in terminal that accepts stdin
map("n", "<leader>R", function()
  vim.cmd("update")
  local src = fe(fp())
  vim.system({ "bash", "-lc", "./run.sh --debug " .. src }, { text = true }, function(r)
    vim.schedule(function()
      if r.code ~= 0 then
        local msg = (r.stderr and #r.stderr > 0 and r.stderr) or (r.stdout or "build failed")
        return vim.notify(msg, vim.log.levels.ERROR, { title = "build failed" })
      end
      local exe = vim.fn.fnamemodify(fp(), ":r")
      if vim.fn.executable(exe) ~= 1 then
        return vim.notify("Built binary not found: " .. exe, vim.log.levels.ERROR, { title = "dap" })
      end
      local cfg = {
        name = "codelldb",
        type = "codelldb",
        request = "launch",
        program = exe,
        cwd = vim.fn.getcwd(),
        args = {},
        stopOnEntry = false,
        console = "integratedTerminal", -- critical: stdin goes to DAP terminal
      }
      dap.run(cfg)
    end)
  end)
end, { desc = "build debug + debug" })

-- optional: :make -> run.sh %
vim.opt.makeprg = "./run.sh %"
map("n", "<leader>m", ":make<CR>", { desc = "make → run.sh %" })
