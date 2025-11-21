require "test_helper"

class BibleNavigationFlowTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:john)
    @chapter = chapters(:john_chapter_1)
    @verse = verses(:john_1_1)
  end

  test "complete user flow: browse books, chapters, and verses" do
    # User starts at home
    get root_url
    assert_response :success

    # User navigates to a specific book
    get bible_book_url(@book)
    assert_response :redirect

    # User views a chapter
    get bible_chapter_url(@book, @chapter.chapter_number)
    assert_response :success
    assert_select "body" # Page renders

    # User views a specific verse
    get bible_verse_url(@book, @chapter.chapter_number, @verse.verse_number)
    assert_response :success
    assert_select "body" # Page renders
  end

  test "user can navigate between verses" do
    # Start at Genesis 1:1
    verse1 = verses(:genesis_1_1)
    verse2 = verses(:genesis_1_2)

    get bible_verse_url(verse1.chapter.book, verse1.chapter.chapter_number, verse1.verse_number)
    assert_response :success

    # Navigate to next verse
    get bible_verse_url(verse2.chapter.book, verse2.chapter.chapter_number, verse2.verse_number)
    assert_response :success
  end

  test "user can navigate between chapters" do
    chapter1 = chapters(:genesis_chapter_1)
    chapter2 = chapters(:genesis_chapter_2)

    get bible_chapter_url(chapter1.book, chapter1.chapter_number)
    assert_response :success

    get bible_chapter_url(chapter2.book, chapter2.chapter_number)
    assert_response :success
  end

  test "user cannot access non-existent verse" do
    get bible_verse_url(@book, @chapter.chapter_number, 999)
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "user cannot access non-existent book" do
    get bible_book_url(book_id: 999999)
    assert_response :redirect
    assert_match %r{^http://www\.example\.com/}, response.redirect_url
  end
end
