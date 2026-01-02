local helper = require('test.helper')

describe('kanji-jump', function()
  local kanji_jump

  before_each(function()
    helper.reset()
    package.loaded['kanji-jump'] = nil
    package.loaded['kanji-jump.config'] = nil
    kanji_jump = require('kanji-jump')
    kanji_jump.setup({ default_mappings = false })
  end)

  describe('is_kanji()', function()
    it('returns true for CJK Unified Ideographs', function()
      assert.is_true(kanji_jump.is_kanji('漢'))
      assert.is_true(kanji_jump.is_kanji('字'))
      assert.is_true(kanji_jump.is_kanji('一'))
      assert.is_true(kanji_jump.is_kanji('龯'))
    end)

    it('returns true for CJK Extension A', function()
      assert.is_true(kanji_jump.is_kanji('㐀'))
    end)

    it('returns false for hiragana', function()
      assert.is_false(kanji_jump.is_kanji('あ'))
      assert.is_false(kanji_jump.is_kanji('ん'))
    end)

    it('returns false for katakana', function()
      assert.is_false(kanji_jump.is_kanji('ア'))
      assert.is_false(kanji_jump.is_kanji('ン'))
    end)

    it('returns false for ASCII', function()
      assert.is_false(kanji_jump.is_kanji('a'))
      assert.is_false(kanji_jump.is_kanji('1'))
    end)

    it('returns false for empty string', function()
      assert.is_false(kanji_jump.is_kanji(''))
      assert.is_false(kanji_jump.is_kanji(nil))
    end)
  end)

  describe('next_kanji()', function()
    -- 吾(1) 輩(4) は(7) 猫(10)
    it('jumps to next kanji', function()
      helper.set_lines({ '吾輩は猫である' })
      helper.set_cursor(1, 1)

      kanji_jump.next_kanji()

      assert.are.same({ 1, 4 }, helper.get_cursor())
    end)

    -- あ(1) い(4) う(7) 漢(10) 字(13)
    it('jumps across non-kanji characters', function()
      helper.set_lines({ 'あいう漢字' })
      helper.set_cursor(1, 1)

      kanji_jump.next_kanji()

      assert.are.same({ 1, 10 }, helper.get_cursor())
    end)

    it('jumps to next line', function()
      helper.set_lines({ 'あいう', '漢字' })
      helper.set_cursor(1, 1)

      kanji_jump.next_kanji()

      assert.are.same({ 2, 1 }, helper.get_cursor())
    end)
  end)

  describe('prev_kanji()', function()
    -- 吾(1) 輩(4) は(7) 猫(10)
    it('jumps to previous kanji', function()
      helper.set_lines({ '吾輩は猫である' })
      helper.set_cursor(1, 10)

      kanji_jump.prev_kanji()

      assert.are.same({ 1, 4 }, helper.get_cursor())
    end)

    it('jumps to previous line', function()
      helper.set_lines({ '漢字', 'あいう' })
      helper.set_cursor(2, 1)

      kanji_jump.prev_kanji()

      assert.are.same({ 1, 4 }, helper.get_cursor())
    end)
  end)

  describe('next_kanji_block()', function()
    -- 今(1) 日(4) も(7) 朝(10) 起(13) き(16) て(19) 夜(22) 寝(25)
    it('jumps to next block', function()
      helper.set_lines({ '今日も朝起きて夜寝る' })
      helper.set_cursor(1, 1)

      kanji_jump.next_kanji_block()

      assert.are.same({ 1, 10 }, helper.get_cursor())
    end)

    it('jumps from middle of block to next block', function()
      helper.set_lines({ '今日も朝起きて夜寝る' })
      helper.set_cursor(1, 4)

      kanji_jump.next_kanji_block()

      assert.are.same({ 1, 10 }, helper.get_cursor())
    end)

    it('jumps from non-kanji to next block', function()
      helper.set_lines({ 'あいう漢字' })
      helper.set_cursor(1, 1)

      kanji_jump.next_kanji_block()

      assert.are.same({ 1, 10 }, helper.get_cursor())
    end)
  end)

  describe('prev_kanji_block()', function()
    -- 今(1) 日(4) も(7) 朝(10) 起(13)
    it('jumps to block start when in middle', function()
      helper.set_lines({ '今日も朝起きて' })
      helper.set_cursor(1, 13)

      kanji_jump.prev_kanji_block()

      assert.are.same({ 1, 10 }, helper.get_cursor())
    end)

    it('jumps to previous block when at block start', function()
      helper.set_lines({ '今日も朝起きて' })
      helper.set_cursor(1, 10)

      kanji_jump.prev_kanji_block()

      assert.are.same({ 1, 1 }, helper.get_cursor())
    end)

    it('jumps from non-kanji to previous block start', function()
      helper.set_lines({ '漢字あいう' })
      helper.set_cursor(1, 7)

      kanji_jump.prev_kanji_block()

      assert.are.same({ 1, 1 }, helper.get_cursor())
    end)
  end)

  describe('repeat motions', function()
    it('repeat_last_motion() returns false when no motion', function()
      assert.is_false(kanji_jump.repeat_last_motion())
    end)

    it('repeat_last_motion() repeats after next_kanji', function()
      helper.set_lines({ '一二三四五' })
      helper.set_cursor(1, 1)

      kanji_jump.next_kanji()
      kanji_jump.repeat_last_motion()

      assert.are.same({ 1, 7 }, helper.get_cursor())
    end)

    it('repeat_last_motion_reverse() goes backward after next_kanji', function()
      helper.set_lines({ '一二三四五' })
      helper.set_cursor(1, 4)

      kanji_jump.next_kanji()
      kanji_jump.repeat_last_motion_reverse()

      assert.are.same({ 1, 4 }, helper.get_cursor())
    end)

    it('clear_last_motion() clears the motion', function()
      helper.set_lines({ '一二三' })
      helper.set_cursor(1, 1)

      kanji_jump.next_kanji()
      kanji_jump.clear_last_motion()

      assert.is_false(kanji_jump.repeat_last_motion())
    end)
  end)
end)
