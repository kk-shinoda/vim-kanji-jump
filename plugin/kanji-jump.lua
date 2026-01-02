if vim.g.loaded_kanji_jump then
  return
end
vim.g.loaded_kanji_jump = true

if vim.fn.has('nvim-0.8') == 0 then
  vim.api.nvim_err_writeln('kanji-jump requires Neovim 0.8 or later')
  return
end

vim.api.nvim_create_user_command('KanjiJumpNext', function()
  require('kanji-jump').next_kanji()
end, { desc = 'Jump to next kanji' })

vim.api.nvim_create_user_command('KanjiJumpPrev', function()
  require('kanji-jump').prev_kanji()
end, { desc = 'Jump to previous kanji' })

vim.api.nvim_create_user_command('KanjiJumpNextBlock', function()
  require('kanji-jump').next_kanji_block()
end, { desc = 'Jump to next kanji block' })

vim.api.nvim_create_user_command('KanjiJumpPrevBlock', function()
  require('kanji-jump').prev_kanji_block()
end, { desc = 'Jump to previous kanji block' })
