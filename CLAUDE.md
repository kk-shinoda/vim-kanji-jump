# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Neovim 用漢字ジャンププラグイン。Neovim 0.8.0+、外部依存なし。

## Commands

```bash
make test   # vusted
make lint   # luacheck
```

## Structure

```
lua/kanji-jump/init.lua    # main
lua/kanji-jump/config.lua  # config
plugin/kanji-jump.lua      # init
test/kanji-jump_spec.lua   # test
```

## Mappings

| Key | Action |
|-----|--------|
| `]k` | next kanji |
| `[k` | prev kanji |
| `]K` | next kanji block |
| `[K` | prev kanji block (or block start if mid-block) |
| `;`  | repeat last kanji jump |
| `,`  | repeat reverse |

## Kanji Block

```
今日も朝起きて夜寝るだけ
^^^  ^^^    ^^^
block1 block2 block3
```

`]K`: block1 → block2
`[K` from middle: → block start
`[K` from start: → prev block start

## Kanji Pattern

```lua
local KANJI_PATTERN = [[\v[一-龯㐀-䶵]]]  -- U+4E00-9FFF, U+3400-4DBF
```

## Config

```lua
require('kanji-jump').setup({
  default_mappings = true,
  mappings = { next_kanji = ']k', prev_kanji = '[k', next_kanji_block = ']K', prev_kanji_block = '[K' },
  wrap = false,
  repeat_motions = true,
})
```

## API

```lua
local kj = require('kanji-jump')
kj.next_kanji()
kj.prev_kanji()
kj.next_kanji_block()
kj.prev_kanji_block()
kj.is_kanji(char)
kj.repeat_last_motion()
kj.repeat_last_motion_reverse()
kj.clear_last_motion()
```

## Implementation Notes

- Use `vim.fn.search()` (C impl, fast)
- Modes: `{'n', 'x', 'o'}` for operator support
- Count: `vim.v.count1`
