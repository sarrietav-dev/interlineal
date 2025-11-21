require "test_helper"

class ChapterTest < ActiveSupport::TestCase
  # Validation tests
  test "should be valid with valid attributes" do
    chapter = Chapter.new(book: books(:genesis), chapter_number: 10)
    assert chapter.valid?
  end

  test "should require chapter_number" do
    chapter = Chapter.new(book: books(:genesis))
    assert_not chapter.valid?
    assert_includes chapter.errors[:chapter_number], "can't be blank"
  end

  test "should require positive chapter_number" do
    chapter = Chapter.new(book: books(:genesis), chapter_number: 0)
    assert_not chapter.valid?
    assert_includes chapter.errors[:chapter_number], "must be greater than 0"

    chapter.chapter_number = -1
    assert_not chapter.valid?
  end

  test "should require unique chapter_number per book" do
    existing = chapters(:genesis_chapter_1)
    chapter = Chapter.new(book: existing.book, chapter_number: existing.chapter_number)
    assert_not chapter.valid?
    assert_includes chapter.errors[:chapter_number], "has already been taken"
  end

  test "should allow same chapter_number for different books" do
    # Genesis has chapter 1, now create chapter 1 for a different book
    chapter = Chapter.new(book: books(:exodus), chapter_number: 1)
    assert chapter.valid?
  end

  # Association tests
  test "should belong to book" do
    chapter = chapters(:genesis_chapter_1)
    assert_respond_to chapter, :book
    assert_instance_of Book, chapter.book
  end

  test "should have many verses" do
    chapter = chapters(:genesis_chapter_1)
    assert_respond_to chapter, :verses
    assert_kind_of ActiveRecord::Associations::CollectionProxy, chapter.verses
  end

  test "should destroy associated verses when destroyed" do
    chapter = chapters(:genesis_chapter_1)
    verse_ids = chapter.verses.pluck(:id)
    chapter.destroy
    verse_ids.each do |id|
      assert_nil Verse.find_by(id: id)
    end
  end

  test "should have words through verses" do
    chapter = chapters(:john_chapter_1)
    assert_respond_to chapter, :words
    assert chapter.words.count > 0
  end

  # Scope tests
  test "by_number scope should order chapters by chapter_number" do
    book = books(:genesis)
    chapters = book.chapters.by_number
    numbers = chapters.pluck(:chapter_number)
    assert_equal numbers.sort, numbers
  end

  test "for_book scope should return chapters for specific book" do
    book = books(:genesis)
    chapters = Chapter.for_book(book.id)
    assert chapters.all? { |chapter| chapter.book_id == book.id }
  end

  # Instance method tests
  test "full_reference should return book name with chapter number" do
    chapter = chapters(:genesis_chapter_1)
    assert_equal "Genesis 1", chapter.full_reference
  end

  test "verse_count should return correct count" do
    chapter = chapters(:genesis_chapter_1)
    assert_equal 3, chapter.verse_count
  end

  test "word_count should return correct count" do
    chapter = chapters(:genesis_chapter_1)
    assert chapter.word_count > 0
  end

  test "next_chapter should return next chapter in book" do
    chapter = chapters(:genesis_chapter_1)
    next_chapter = chapter.next_chapter
    assert_equal chapters(:genesis_chapter_2), next_chapter
    assert_equal 2, next_chapter.chapter_number
  end

  test "next_chapter should return nil for last chapter" do
    chapter = chapters(:genesis_chapter_2)
    assert_nil chapter.next_chapter
  end

  test "previous_chapter should return previous chapter in book" do
    chapter = chapters(:genesis_chapter_2)
    prev_chapter = chapter.previous_chapter
    assert_equal chapters(:genesis_chapter_1), prev_chapter
    assert_equal 1, prev_chapter.chapter_number
  end

  test "previous_chapter should return nil for first chapter" do
    chapter = chapters(:genesis_chapter_1)
    assert_nil chapter.previous_chapter
  end

  # Callback tests
  test "should touch associated book after update" do
    chapter = chapters(:genesis_chapter_1)
    book = chapter.book
    original_updated_at = book.updated_at

    travel_to 1.day.from_now do
      chapter.update(chapter_number: 99)
      book.reload
      assert_operator book.updated_at, :>, original_updated_at
    end
  end
end
