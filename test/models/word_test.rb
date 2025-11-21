require "test_helper"

class WordTest < ActiveSupport::TestCase
  # Validation tests
  test "should be valid with valid attributes" do
    word = Word.new(verse: verses(:genesis_1_1), word_order: 10, greek_word: "test")
    assert word.valid?
  end

  test "should require word_order" do
    word = Word.new(verse: verses(:genesis_1_1), greek_word: "test")
    assert_not word.valid?
    assert_includes word.errors[:word_order], "can't be blank"
  end

  test "should require positive word_order" do
    word = Word.new(verse: verses(:genesis_1_1), word_order: 0)
    assert_not word.valid?
    assert_includes word.errors[:word_order], "must be greater than 0"
  end

  test "should require unique word_order per verse" do
    existing = words(:genesis_1_1_word_1)
    word = Word.new(verse: existing.verse, word_order: existing.word_order)
    assert_not word.valid?
    assert_includes word.errors[:word_order], "has already been taken"
  end

  test "should allow same word_order for different verses" do
    # Genesis 1:1 has word_order 1, now create word_order 1 for different verse
    word = Word.new(verse: verses(:john_1_14), word_order: 1, greek_word: "test")
    assert word.valid?
  end

  # Association tests
  test "should belong to verse" do
    word = words(:genesis_1_1_word_1)
    assert_respond_to word, :verse
    assert_instance_of Verse, word.verse
  end

  test "should optionally belong to strong" do
    word = words(:genesis_1_1_word_1)
    assert_respond_to word, :strong
  end

  test "should have chapter through verse" do
    word = words(:genesis_1_1_word_1)
    assert_respond_to word, :chapter
    assert_instance_of Chapter, word.chapter
  end

  test "should have book through chapter" do
    word = words(:genesis_1_1_word_1)
    assert_respond_to word, :book
    assert_instance_of Book, word.book
  end

  # Scope tests
  test "by_order scope should order words by word_order" do
    verse = verses(:genesis_1_1)
    words = verse.words.by_order
    orders = words.pluck(:word_order)
    assert_equal orders.sort, orders
  end

  test "for_verse scope should return words for specific verse" do
    verse = verses(:genesis_1_1)
    words = Word.for_verse(verse.id)
    assert words.all? { |word| word.verse_id == verse.id }
  end

  test "with_strongs scope should return only words with strong numbers" do
    words = Word.with_strongs
    assert words.all? { |word| word.strong_number.present? }
  end

  test "with_greek scope should return only words with greek text" do
    words = Word.with_greek
    assert words.all? { |word| word.greek_word.present? }
  end

  test "with_hebrew scope should return only words with hebrew text" do
    words = Word.with_hebrew
    assert words.all? { |word| word.hebrew_word.present? }
  end

  test "with_spanish scope should return only words with spanish translation" do
    words = Word.with_spanish
    assert words.all? { |word| word.spanish_translation.present? }
  end

  test "greek scope should return only greek words" do
    words = Word.greek
    assert words.all? { |word| word.language == "greek" }
  end

  test "hebrew scope should return only hebrew words" do
    words = Word.hebrew
    assert words.all? { |word| word.language == "hebrew" }
  end

  # Instance method tests
  test "full_reference should return complete reference with word order" do
    word = words(:genesis_1_1_word_1)
    assert_equal "Genesis 1:1:1", word.full_reference
  end

  test "display_greek should return greek word or N/A" do
    greek_word = words(:john_1_1_word_1)
    assert_equal greek_word.greek_word, greek_word.display_greek

    hebrew_word = words(:genesis_1_1_word_1)
    if hebrew_word.greek_word.blank?
      assert_equal "N/A", hebrew_word.display_greek
    end
  end

  test "display_hebrew should return hebrew word or N/A" do
    hebrew_word = words(:genesis_1_1_word_1)
    assert_equal hebrew_word.hebrew_word, hebrew_word.display_hebrew

    greek_word = words(:john_1_1_word_1)
    if greek_word.hebrew_word.blank?
      assert_equal "N/A", greek_word.display_hebrew
    end
  end

  test "display_spanish should return spanish translation or N/A" do
    word = words(:genesis_1_1_word_1)
    if word.spanish_translation.present?
      assert_equal word.spanish_translation, word.display_spanish
    else
      assert_equal "N/A", word.display_spanish
    end
  end

  test "display_strong should format hebrew strong numbers with H prefix" do
    word = words(:genesis_1_1_word_1)
    assert_equal "H#{word.strong_number}", word.display_strong
  end

  test "display_strong should format greek strong numbers with G prefix" do
    word = words(:john_1_1_word_1)
    assert_equal "G#{word.strong_number}", word.display_strong
  end

  test "display_strong should return N/A when no strong number" do
    word = Word.new(verse: verses(:genesis_1_1), word_order: 99)
    assert_equal "N/A", word.display_strong
  end

  test "has_strong_definition should return true when strong is present" do
    word = words(:genesis_1_1_word_1)
    if word.strong.present?
      assert word.has_strong_definition?
    end
  end

  test "has_strong_definition should return false when strong is absent" do
    word = Word.new(verse: verses(:genesis_1_1), word_order: 99)
    assert_not word.has_strong_definition?
  end

  test "strong_definition should return definition from associated strong" do
    word = words(:genesis_1_1_word_1)
    if word.strong.present?
      assert_equal word.strong.full_definition, word.strong_definition
    end
  end

  test "searchable_text should combine all relevant fields" do
    word = words(:genesis_1_1_word_1)
    searchable = word.searchable_text
    assert_kind_of String, searchable
    assert searchable.length > 0
  end

  test "language should return hebrew for hebrew words" do
    word = words(:genesis_1_1_word_1)
    assert_equal "hebrew", word.language
  end

  test "language should return greek for greek words" do
    word = words(:john_1_1_word_1)
    assert_equal "greek", word.language
  end

  # Callback tests
  test "should touch associated verse after update" do
    word = words(:genesis_1_1_word_1)
    verse = word.verse
    original_updated_at = verse.updated_at

    travel_to 1.day.from_now do
      word.update(spanish_translation: "Updated")
      verse.reload
      assert_operator verse.updated_at, :>, original_updated_at
    end
  end
end
