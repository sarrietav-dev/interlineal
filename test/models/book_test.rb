require "test_helper"

class BookTest < ActiveSupport::TestCase
  # Validation tests
  test "should be valid with valid attributes" do
    book = Book.new(name: "Test Book", abbreviation: "TST", testament: "NT")
    assert book.valid?
  end

  test "should require name" do
    book = Book.new(abbreviation: "TST", testament: "NT")
    assert_not book.valid?
    assert_includes book.errors[:name], "can't be blank"
  end

  test "should require abbreviation" do
    book = Book.new(name: "Test Book", testament: "NT")
    assert_not book.valid?
    assert_includes book.errors[:abbreviation], "can't be blank"
  end

  test "should require testament" do
    book = Book.new(name: "Test Book", abbreviation: "TST")
    assert_not book.valid?
    assert_includes book.errors[:testament], "can't be blank"
  end

  test "should only allow OT or NT as testament" do
    book = Book.new(name: "Test Book", abbreviation: "TST", testament: "INVALID")
    assert_not book.valid?
    assert_includes book.errors[:testament], "is not included in the list"
  end

  # Association tests
  test "should have many chapters" do
    book = books(:genesis)
    assert_respond_to book, :chapters
    assert_kind_of ActiveRecord::Associations::CollectionProxy, book.chapters
  end

  test "should destroy associated chapters when destroyed" do
    book = books(:genesis)
    chapter_ids = book.chapters.pluck(:id)
    book.destroy
    chapter_ids.each do |id|
      assert_nil Chapter.find_by(id: id)
    end
  end

  test "should have verses through chapters" do
    book = books(:john)
    assert_respond_to book, :verses
    assert book.verses.count > 0
  end

  test "should have words through verses" do
    book = books(:john)
    assert_respond_to book, :words
    assert book.words.count > 0
  end

  # Scope tests
  test "new_testament scope should return only NT books" do
    nt_books = Book.new_testament
    assert nt_books.all? { |book| book.testament == "NT" }
    assert_includes nt_books, books(:john)
    assert_not_includes nt_books, books(:genesis)
  end

  test "old_testament scope should return only OT books" do
    ot_books = Book.old_testament
    assert ot_books.all? { |book| book.testament == "OT" }
    assert_includes ot_books, books(:genesis)
    assert_not_includes ot_books, books(:john)
  end

  test "by_name scope should order books by id" do
    books = Book.by_name
    ids = books.pluck(:id)
    assert_equal ids.sort, ids
  end

  # Instance method tests
  test "full_name should return name with abbreviation" do
    book = books(:genesis)
    assert_equal "Genesis (Gen)", book.full_name
  end

  test "chapter_count should return correct count" do
    book = books(:genesis)
    assert_equal 2, book.chapter_count
  end

  test "verse_count should return correct count" do
    book = books(:genesis)
    assert_equal 3, book.verse_count
  end

  test "word_count should return correct count" do
    book = books(:genesis)
    assert book.word_count > 0
  end

  # Callback tests
  test "should touch associated chapters after update" do
    book = books(:genesis)
    chapter = book.chapters.first
    original_updated_at = chapter.updated_at

    travel_to 1.day.from_now do
      book.update(name: "Genesis Updated")
      chapter.reload
      assert_operator chapter.updated_at, :>, original_updated_at
    end
  end
end
