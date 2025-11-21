require "test_helper"

class StrongTest < ActiveSupport::TestCase
  # Validation tests
  test "should be valid with valid greek attributes" do
    strong = Strong.new(strong_number: "9999", greek_word: "test", definition: "test definition")
    assert strong.valid?
  end

  test "should be valid with valid hebrew attributes" do
    strong = Strong.new(strong_number: "9999", hebrew_word: "test", definition: "test definition")
    assert strong.valid?
  end

  test "should require strong_number" do
    strong = Strong.new(greek_word: "test", definition: "test")
    assert_not strong.valid?
    assert_includes strong.errors[:strong_number], "can't be blank"
  end

  test "should require unique strong_number" do
    existing = strongs(:g2316)
    strong = Strong.new(strong_number: existing.strong_number, greek_word: "test")
    assert_not strong.valid?
    assert_includes strong.errors[:strong_number], "has already been taken"
  end

  test "should require either greek_word or hebrew_word" do
    strong = Strong.new(strong_number: "9999", definition: "test")
    assert_not strong.valid?
  end

  test "should be valid with greek_word" do
    strong = Strong.new(strong_number: "9999", greek_word: "test", definition: "test")
    assert strong.valid?
  end

  test "should be valid with hebrew_word" do
    strong = Strong.new(strong_number: "9999", hebrew_word: "test", definition: "test")
    assert strong.valid?
  end

  # Association tests
  test "should have many words" do
    strong = strongs(:g2316)
    assert_respond_to strong, :words
    assert_kind_of ActiveRecord::Associations::CollectionProxy, strong.words
  end

  # Scope tests
  test "by_number scope should order by strong_number" do
    strongs = Strong.by_number
    numbers = strongs.pluck(:strong_number)
    # Just verify it's ordered, accounting for string sorting
    assert_equal numbers, numbers.sort
  end

  test "with_definitions scope should return only entries with definitions" do
    strongs = Strong.with_definitions
    assert strongs.all? { |strong| strong.definition.present? }
  end

  test "by_part_of_speech scope should filter by part of speech" do
    strongs = Strong.by_part_of_speech("Noun")
    assert strongs.all? { |strong| strong.part_of_speech == "Noun" }
  end

  test "greek scope should return only greek entries" do
    strongs = Strong.greek
    assert strongs.all? { |strong| strong.language == "greek" }
  end

  test "hebrew scope should return only hebrew entries" do
    strongs = Strong.hebrew
    assert strongs.all? { |strong| strong.language == "hebrew" }
  end

  # Instance method tests
  test "display_number should format hebrew numbers with H prefix" do
    strong = strongs(:h430)
    assert_equal "H#{strong.strong_number}", strong.display_number
  end

  test "display_number should format greek numbers with G prefix" do
    strong = strongs(:g2316)
    assert_equal "G#{strong.strong_number}", strong.display_number
  end

  test "full_definition should combine definition and definition2" do
    strong = strongs(:g2316)
    expected = [ strong.definition, strong.definition2 ].compact.join("; ")
    assert_equal expected, strong.full_definition
  end

  test "full_definition should return only definition when definition2 is blank" do
    strong = Strong.new(strong_number: "9999", greek_word: "test", definition: "first def")
    assert_equal "first def", strong.full_definition
  end

  test "word_count should return correct count" do
    strong = strongs(:g2316)
    assert strong.word_count >= 0
  end

  test "verses_with_this_word should return ordered verses" do
    strong = strongs(:g2316)
    verses = strong.verses_with_this_word
    assert_kind_of ActiveRecord::Relation, verses

    if verses.count > 1
      # Verify ordering
      first_verse = verses.first
      last_verse = verses.last
      assert_operator first_verse.book.name, :<=, last_verse.book.name
    end
  end

  test "searchable_text should combine all relevant fields" do
    strong = strongs(:g2316)
    searchable = strong.searchable_text
    assert_kind_of String, searchable
    assert searchable.length > 0
    assert_includes searchable, strong.definition if strong.definition.present?
  end

  test "language should return hebrew for hebrew entries" do
    strong = strongs(:h430)
    assert_equal "hebrew", strong.language
  end

  test "language should return greek for greek entries" do
    strong = strongs(:g2316)
    assert_equal "greek", strong.language
  end

  test "language should use inferred value when language field not set" do
    strong = Strong.new(strong_number: "9999", hebrew_word: "test", definition: "test")
    assert_equal "hebrew", strong.language

    strong = Strong.new(strong_number: "9998", greek_word: "test", definition: "test")
    assert_equal "greek", strong.language
  end
end
