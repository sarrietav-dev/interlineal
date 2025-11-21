require "test_helper"

class VerseTest < ActiveSupport::TestCase
  # Validation tests
  test "should be valid with valid attributes" do
    verse = Verse.new(chapter: chapters(:genesis_chapter_1), verse_number: 10, spanish_text: "Test text")
    assert verse.valid?
  end

  test "should require verse_number" do
    verse = Verse.new(chapter: chapters(:genesis_chapter_1), spanish_text: "Test text")
    assert_not verse.valid?
    assert_includes verse.errors[:verse_number], "can't be blank"
  end

  test "should require positive verse_number" do
    verse = Verse.new(chapter: chapters(:genesis_chapter_1), verse_number: 0)
    assert_not verse.valid?
    assert_includes verse.errors[:verse_number], "must be greater than 0"
  end

  test "should require unique verse_number per chapter" do
    existing = verses(:genesis_1_1)
    verse = Verse.new(chapter: existing.chapter, verse_number: existing.verse_number)
    assert_not verse.valid?
    assert_includes verse.errors[:verse_number], "has already been taken"
  end

  test "should allow same verse_number for different chapters" do
    # Genesis chapter 1 has verse 1, now create verse 1 for different chapter
    verse = Verse.new(chapter: chapters(:genesis_chapter_2), verse_number: 1, spanish_text: "Test")
    assert verse.valid?
  end

  # Association tests
  test "should belong to chapter" do
    verse = verses(:genesis_1_1)
    assert_respond_to verse, :chapter
    assert_instance_of Chapter, verse.chapter
  end

  test "should have book through chapter" do
    verse = verses(:genesis_1_1)
    assert_respond_to verse, :book
    assert_instance_of Book, verse.book
    assert_equal verse.chapter.book, verse.book
  end

  test "should have many words" do
    verse = verses(:genesis_1_1)
    assert_respond_to verse, :words
    assert_kind_of ActiveRecord::Associations::CollectionProxy, verse.words
  end

  test "should destroy associated words when destroyed" do
    verse = verses(:genesis_1_1)
    word_ids = verse.words.pluck(:id)
    verse.destroy
    word_ids.each do |id|
      assert_nil Word.find_by(id: id)
    end
  end

  # Scope tests
  test "by_number scope should order verses by verse_number" do
    chapter = chapters(:genesis_chapter_1)
    verses = chapter.verses.by_number
    numbers = verses.pluck(:verse_number)
    assert_equal numbers.sort, numbers
  end

  test "for_chapter scope should return verses for specific chapter" do
    chapter = chapters(:genesis_chapter_1)
    verses = Verse.for_chapter(chapter.id)
    assert verses.all? { |verse| verse.chapter_id == chapter.id }
  end

  test "with_spanish_text scope should return only verses with spanish text" do
    verses = Verse.with_spanish_text
    assert verses.all? { |verse| verse.spanish_text.present? }
  end

  # Instance method tests
  test "full_reference should return complete reference" do
    verse = verses(:genesis_1_1)
    assert_equal "Genesis 1:1", verse.full_reference
  end

  test "word_count should return correct count" do
    verse = verses(:genesis_1_1)
    assert verse.word_count > 0
  end

  test "next_verse should return next verse in chapter" do
    verse = verses(:genesis_1_1)
    next_verse = verse.next_verse
    assert_equal verses(:genesis_1_2), next_verse
    assert_equal 2, next_verse.verse_number
  end

  test "next_verse should return nil for last verse" do
    verse = verses(:genesis_1_3)
    assert_nil verse.next_verse
  end

  test "previous_verse should return previous verse in chapter" do
    verse = verses(:genesis_1_2)
    prev_verse = verse.previous_verse
    assert_equal verses(:genesis_1_1), prev_verse
    assert_equal 1, prev_verse.verse_number
  end

  test "previous_verse should return nil for first verse" do
    verse = verses(:genesis_1_1)
    assert_nil verse.previous_verse
  end

  test "words_by_order should return words ordered by word_order" do
    verse = verses(:genesis_1_1)
    words = verse.words_by_order
    orders = words.pluck(:word_order)
    assert_equal orders.sort, orders
  end

  test "words_with_strongs should return words with strong associations" do
    verse = verses(:genesis_1_1)
    words = verse.words_with_strongs
    assert_not_empty words
    # Verify it's ordered
    orders = words.pluck(:word_order)
    assert_equal orders.sort, orders
  end

  test "cache_key_with_version should include updated_at timestamp" do
    verse = verses(:genesis_1_1)
    cache_key = verse.cache_key_with_version
    assert_includes cache_key, verse.updated_at.to_i.to_s
  end

  # Callback tests
  test "should touch associated chapter after update" do
    verse = verses(:genesis_1_1)
    chapter = verse.chapter
    original_updated_at = chapter.updated_at

    travel_to 1.day.from_now do
      verse.update(spanish_text: "Updated text")
      chapter.reload
      assert_operator chapter.updated_at, :>, original_updated_at
    end
  end
end
