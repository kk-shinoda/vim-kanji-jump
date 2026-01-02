local M = {}

M.defaults = {
  default_mappings = true,
  mappings = {
    next_kanji = ']k',
    prev_kanji = '[k',
    next_kanji_block = ']K',
    prev_kanji_block = '[K',
  },
  wrap = false,
  repeat_motions = true,
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', {}, M.defaults, opts or {})
end

return M
