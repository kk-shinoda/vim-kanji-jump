# vim-kanji-jump

Neovim plugin for jumping between kanji characters in Japanese text.

## Features

- `]k` / `[k`: Jump to next/previous kanji character
- `]K` / `[K`: Jump to next/previous kanji block (consecutive kanji)
- `;` / `,`: Repeat last kanji jump (forward/backward)
- Works across multiple lines
- Supports operators (`d]k`, `c]K`, `y[k`, etc.)
- Supports count (`3]k` to jump 3 kanji ahead)
- Zero dependencies (uses only Neovim built-in APIs)
- Fast (uses Vim's native `search()` function)

## Requirements

- Neovim 0.8.0 or later

## Installation

### lazy.nvim

```lua
{
  'YOUR_USERNAME/vim-kanji-jump',
  config = function()
    require('kanji-jump').setup()
  end,
}
```

### packer.nvim

```lua
use {
  'YOUR_USERNAME/vim-kanji-jump',
  config = function()
    require('kanji-jump').setup()
  end,
}
```

## Usage

| Key | Description |
|-----|-------------|
| `]k` | Jump to next kanji |
| `[k` | Jump to previous kanji |
| `]K` | Jump to next kanji block |
| `[K` | Jump to previous kanji block (or block start if mid-block) |
| `;` | Repeat last kanji jump |
| `,` | Repeat last kanji jump (reverse direction) |

### `;` / `,` behavior

After a kanji jump, `;` repeats the same motion, `,` goes in reverse. After `f`/`t`/`F`/`T`, these keys work as normal Vim behavior.

### What is a "kanji block"?

A kanji block is a sequence of consecutive kanji characters.

```
磁気双極子がある理由についての説明
^^^^^^^^^       ^^^^      ^^^^
Block 1         Block 2   Block 3
```

`]K` jumps from Block 1 to Block 2, skipping individual characters.

### `[K` behavior

- If cursor is **in the middle** of a kanji block → jump to the **start** of the current block
- If cursor is **at the start** of a kanji block → jump to the **start** of the previous block

## Configuration

```lua
require('kanji-jump').setup({
  -- Set to false to disable default mappings
  default_mappings = true,

  -- Custom key mappings
  mappings = {
    next_kanji = ']k',
    prev_kanji = '[k',
    next_kanji_block = ']K',
    prev_kanji_block = '[K',
  },

  -- Wrap around at file boundaries
  wrap = false,

  -- Enable ; / , to repeat kanji jumps
  repeat_motions = true,
})
```

### Disable default mappings

```lua
require('kanji-jump').setup({
  default_mappings = false,
})

-- Define your own mappings
vim.keymap.set('n', '<leader>j', require('kanji-jump').next_kanji)
vim.keymap.set('n', '<leader>k', require('kanji-jump').prev_kanji)
```

## API

```lua
local kj = require('kanji-jump')

kj.next_kanji()        -- Jump to next kanji
kj.prev_kanji()        -- Jump to previous kanji
kj.next_kanji_block()  -- Jump to next kanji block
kj.prev_kanji_block()  -- Jump to previous kanji block
kj.is_kanji(char)      -- Check if character is kanji
```

## License

MIT
