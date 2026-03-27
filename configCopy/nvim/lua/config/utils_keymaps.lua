local M = {}
local sh = vim.fn.shellescape

M.root = vim.fn.stdpath("config")
M.input = M.root .. "/lua/config/temp.txt"

------------ LOCAL BEGIN ------------
local function find_gtest_suite()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  for i = row, 1, -1 do
    local line = (vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1] or "")
    local suite = line:match("TEST_F%s*%(%s*([%w_]+)%s*,") or line:match("TEST%s*%(%s*([%w_]+)%s*,")
    if suite then
      return suite
    end
  end
end
------------ LOCAL END ------------

function M.align_by_next_char()
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
end

function M.run_gtest_here()
  local bin = "./build/tests/vimficiency_tests"
  local name = vim.fn.expand("<cword>")
  local suite = find_gtest_suite()
  if not suite or name == "" then
    vim.notify("Need cursor on test name and a TEST/TEST_F above", vim.log.levels.WARN)
    return
  end
  local filter = suite .. "." .. name
  local build_cmd = "cmake --build build --target vimficiency_tests"
  local run_cmd = bin .. " --gtest_filter=" .. vim.fn.shellescape(filter)

  vim.cmd("only")
  vim.cmd("botright split | resize 15 | terminal " .. build_cmd .. " && " .. run_cmd)

  local buf = vim.api.nvim_get_current_buf()
  vim.keymap.set({"n", "t"}, "q", function()
    vim.cmd("bdelete!")
  end, { buffer = buf, silent = true })
end

function M.add_git_changes_to_quicklist()
  local files = vim.fn.systemlist("git ls-files -m -o --exclude-standard")
  local items = vim.tbl_map(function(f)
    return { filename = f }
  end, files)
  vim.fn.setqflist({}, "r", { title = "git changed files", items = items })
  vim.cmd("copen")
end


local function check_runnable(src)
  if vim.bo.buftype ~= "" then
    vim.notify("Focus a source file.", vim.log.levels.ERROR)
    return false
  end
  vim.cmd("update")
  if src == "" or vim.fn.filereadable(src) ~= 1 then
    vim.notify("Current buffer is not a file.", vim.log.levels.ERROR)
    return false
  end
  if not src:match("%.cpp$") then
    vim.notify("Current file is not a .cpp file.", vim.log.levels.ERROR)
    return false
  end
  return true
end

local function kill_terms()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].buftype == "terminal" then
      local jid = vim.b[b].terminal_job_id
      if jid and jid > 0 then
        pcall(vim.fn.jobstop, jid)
      end
      pcall(vim.api.nvim_buf_delete, b, { force = true })
    end
  end
end

local function run_term(cmd)
  kill_terms()
  vim.cmd("silent! only")
  vim.cmd("botright vsplit")
  vim.cmd("execute 'terminal ' .. " .. vim.fn.string("bash -lc " .. sh(cmd)))
  vim.cmd("startinsert")
end

local function build_run_cmd(src, opts)
  opts = opts or {}
  local exe = vim.fn.fnamemodify(src, ":r")
  local input = opts.input or M.input
  local timeout = opts.timeout or "30s"
  local flags = opts.flags or "-std=gnu++23 -O2 -pipe"

  local compile = string.format(
    "g++ %s %s -o %s",
    flags,
    sh(src),
    sh(exe)
  )

  if opts.mode == "replay" then
    return string.format(
      "mkdir -p %s && touch %s && cat %s && %s && timeout %s %s < %s; res=$?; rm -f %s; exit $res",
      sh(vim.fn.fnamemodify(input, ":h")),
      sh(input),
      sh(input),
      compile,
      sh(timeout),
      sh(exe),
      sh(input),
      sh(exe)
    )
  end

  return string.format(
    "mkdir -p %s && touch %s && %s && tee %s | timeout %s %s; res=$?; rm -f %s; exit $res",
    sh(vim.fn.fnamemodify(input, ":h")),
    sh(input),
    compile,
    sh(input),
    sh(timeout),
    sh(exe),
    sh(exe)
  )
end

function M.run_cpp()
  local src = vim.fn.expand("%:p")
  if not check_runnable(src) then
    return
  end
  run_term(build_run_cmd(src, { mode = "record" }))
end

function M.run_cpp_input()
  local src = vim.fn.expand("%:p")
  if not check_runnable(src) then
    return
  end
  run_term(build_run_cmd(src, { mode = "replay" }))
end

return M
