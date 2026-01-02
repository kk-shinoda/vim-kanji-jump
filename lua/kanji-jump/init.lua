local M = {}
local config = require('kanji-jump.config')

local last_motion = nil

local KANJI_PATTERN = [=[\v[一-龯㐀-䶵]]=]
local NON_KANJI_PATTERN = [=[\v[^一-龯㐀-䶵]]=]

local function get_char_under_cursor()
  local col = vim.fn.col('.')
  return vim.fn.matchstr(vim.fn.getline('.'), [[\%]] .. col .. [[c.]])
end

local function get_search_flags(backward)
  if config.options.wrap then
    return backward and 'bw' or 'w'
  end
  return backward and 'bW' or 'W'
end

local function find_block_start()
  if vim.fn.search(NON_KANJI_PATTERN, 'bW') ~= 0 then
    vim.fn.search(KANJI_PATTERN, 'W')
  else
    vim.cmd('normal! gg0')
    if not M.is_kanji(get_char_under_cursor()) then
      vim.fn.search(KANJI_PATTERN, 'W')
    end
  end
end

local function setup_mappings()
  local mappings = config.options.mappings
  local modes = { 'n', 'x', 'o' }

  vim.keymap.set(modes, mappings.next_kanji, M.next_kanji, {
    desc = 'Jump to next kanji',
    silent = true,
  })

  vim.keymap.set(modes, mappings.prev_kanji, M.prev_kanji, {
    desc = 'Jump to previous kanji',
    silent = true,
  })

  vim.keymap.set(modes, mappings.next_kanji_block, M.next_kanji_block, {
    desc = 'Jump to next kanji block',
    silent = true,
  })

  vim.keymap.set(modes, mappings.prev_kanji_block, M.prev_kanji_block, {
    desc = 'Jump to previous kanji block',
    silent = true,
  })
end

local function setup_repeat_mappings()
  local modes = { 'n', 'x', 'o' }

  vim.keymap.set(modes, ';', function()
    if not M.repeat_last_motion() then
      vim.cmd('normal! ;')
    end
  end, { silent = true })

  vim.keymap.set(modes, ',', function()
    if not M.repeat_last_motion_reverse() then
      vim.cmd('normal! ,')
    end
  end, { silent = true })

  for _, key in ipairs({ 'f', 't', 'F', 'T' }) do
    vim.keymap.set(modes, key, function()
      last_motion = nil
      vim.cmd('normal! ' .. key .. vim.fn.getcharstr())
    end, { silent = true })
  end
end

---@param char string
---@return boolean
function M.is_kanji(char)
  if not char or char == '' then
    return false
  end
  return vim.fn.match(char, KANJI_PATTERN) ~= -1
end

function M.next_kanji()
  last_motion = { func = M.next_kanji, reverse_func = M.prev_kanji }
  local flags = get_search_flags(false)
  for _ = 1, vim.v.count1 do
    vim.fn.search(KANJI_PATTERN, flags)
  end
end

function M.prev_kanji()
  last_motion = { func = M.prev_kanji, reverse_func = M.next_kanji }
  local flags = get_search_flags(true)
  for _ = 1, vim.v.count1 do
    vim.fn.search(KANJI_PATTERN, flags)
  end
end

function M.next_kanji_block()
  last_motion = { func = M.next_kanji_block, reverse_func = M.prev_kanji_block }
  local flags = get_search_flags(false)

  for _ = 1, vim.v.count1 do
    if M.is_kanji(get_char_under_cursor()) then
      if vim.fn.search(NON_KANJI_PATTERN, flags) == 0 then
        return
      end
    end
    vim.fn.search(KANJI_PATTERN, flags)
  end
end

function M.prev_kanji_block()
  last_motion = { func = M.prev_kanji_block, reverse_func = M.next_kanji_block }
  local flags = get_search_flags(true)

  for _ = 1, vim.v.count1 do
    local cur_char = get_char_under_cursor()

    if M.is_kanji(cur_char) then
      local save_pos = vim.fn.getpos('.')
      find_block_start()
      local block_start = vim.fn.getpos('.')

      if save_pos[2] == block_start[2] and save_pos[3] == block_start[3] then
        vim.fn.setpos('.', save_pos)
        if vim.fn.search(NON_KANJI_PATTERN, flags) ~= 0 then
          if vim.fn.search(KANJI_PATTERN, flags) ~= 0 then
            find_block_start()
          end
        end
      end
    else
      if vim.fn.search(KANJI_PATTERN, flags) ~= 0 then
        find_block_start()
      end
    end
  end
end

function M.clear_last_motion()
  last_motion = nil
end

function M.repeat_last_motion()
  if last_motion then
    last_motion.func()
    return true
  end
  return false
end

function M.repeat_last_motion_reverse()
  if last_motion then
    last_motion.reverse_func()
    return true
  end
  return false
end

---@param opts table|nil
function M.setup(opts)
  config.setup(opts)

  if config.options.default_mappings then
    setup_mappings()
    if config.options.repeat_motions then
      setup_repeat_mappings()
    end
  end
end

return M
