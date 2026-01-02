local M = {}

function M.reset()
  vim.cmd('enew!')
  vim.bo.buftype = 'nofile'
  vim.bo.swapfile = false
end

function M.set_lines(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

function M.get_lines()
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

function M.set_cursor(row, col)
  vim.api.nvim_win_set_cursor(0, { row, col - 1 })
end

function M.get_cursor()
  local pos = vim.api.nvim_win_get_cursor(0)
  return { pos[1], pos[2] + 1 }
end

return M
