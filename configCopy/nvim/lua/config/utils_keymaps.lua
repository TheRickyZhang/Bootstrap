local M = {}

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

return M
