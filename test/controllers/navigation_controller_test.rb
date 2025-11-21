require "test_helper"

class NavigationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:john)
    @chapter = chapters(:john_chapter_1)
    @verse = verses(:john_1_1)
    Rails.cache.clear
  end

  # Show action tests
  test "should get show" do
    get navigation_url(book_id: @book.id, chapter_number: @chapter.chapter_number, verse_number: @verse.verse_number)
    assert_response :success
    assert_not_nil assigns(:all_books)
    assert_not_nil assigns(:navigation_data)
  end

  test "should load navigation data" do
    get navigation_url(book_id: @book.id, chapter_number: @chapter.chapter_number)
    assert_response :success
    assert_equal @book.id.to_s, assigns(:book_id)
    assert_equal @chapter.chapter_number.to_s, assigns(:chapter_number)
    assert_not_nil assigns(:book)
    assert_not_nil assigns(:chapters)
  end

  test "should handle missing book_id gracefully" do
    get navigation_url
    assert_response :success
    assert_not_nil assigns(:all_books)
  end

  # Update action tests
  test "should redirect to slideshow with valid params" do
    patch navigation_path, params: {
      book_id: @book.id,
      chapter_number: @chapter.chapter_number,
      verse_number: @verse.verse_number
    }
    assert_response :redirect
    assert_match %r{/slideshow/#{@book.id}/#{@chapter.chapter_number}/#{@verse.verse_number}}, response.redirect_url
  end

  test "should handle update with navigation hash params" do
    patch navigation_path, params: {
      navigation: {
        book_id: @book.id,
        chapter_number: @chapter.chapter_number,
        verse_number: @verse.verse_number
      }
    }
    assert_response :redirect
    assert_match %r{/slideshow/#{@book.id}/#{@chapter.chapter_number}/#{@verse.verse_number}}, response.redirect_url
  end

  test "should render show when params incomplete" do
    patch navigation_path, params: { book_id: @book.id }
    assert_response :success
  end

  # Select book tests
  test "should select book and load chapters" do
    get select_book_navigation_url, params: { book_id: @book.id }, as: :turbo_stream
    assert_response :success
    assert_equal @book.id.to_s, assigns(:book_id)
    assert_not_nil assigns(:book)
    assert_not_nil assigns(:chapters)
  end

  test "should handle invalid book_id in select_book" do
    get select_book_navigation_url, params: { book_id: 999999 }, as: :turbo_stream
    assert_response :success
    # Should fall back to first book
    assert_not_nil assigns(:book)
  end

  test "should load first chapter verses when selecting book" do
    get select_book_navigation_url, params: { book_id: @book.id }, as: :turbo_stream
    assert_response :success
    assert_not_nil assigns(:chapter)
    assert_not_nil assigns(:verses)
  end

  # Select chapter tests
  test "should select chapter and load verses" do
    get select_chapter_navigation_url, params: {
      book_id: @book.id,
      chapter_number: @chapter.chapter_number
    }, as: :turbo_stream
    assert_response :success
    assert_equal @book.id.to_s, assigns(:book_id)
    assert_equal @chapter.chapter_number.to_s, assigns(:chapter_number)
    assert_not_nil assigns(:chapter)
    assert_not_nil assigns(:verses)
  end

  test "should handle invalid chapter in select_chapter" do
    get select_chapter_navigation_url, params: {
      book_id: @book.id,
      chapter_number: 999
    }, as: :turbo_stream
    assert_response :success
    assert_equal [], assigns(:verses)
  end

  test "should handle invalid book_id in select_chapter" do
    get select_chapter_navigation_url, params: {
      book_id: 999999,
      chapter_number: 1
    }, as: :turbo_stream
    assert_response :success
    # Should fall back to first book
    assert_not_nil assigns(:book)
  end

  # Close action tests
  test "should close navigation modal" do
    get close_navigation_url, as: :turbo_stream
    assert_response :success
  end

  # Cache tests
  test "should use cache for all books data" do
    # Enable memory store for this test
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    begin
      get navigation_url(book_id: @book.id)
      assert_response :success

      # Verify cache was populated
      cached_books = Rails.cache.read("all_books_with_chapters")
      assert_not_nil cached_books
    ensure
      Rails.cache = original_cache
    end
  end

  # Integration tests
  test "should handle complete navigation flow" do
    # Start with navigation page
    get navigation_url
    assert_response :success

    # Select a book
    get select_book_navigation_url, params: { book_id: @book.id }, as: :turbo_stream
    assert_response :success

    # Select a chapter
    get select_chapter_navigation_url, params: {
      book_id: @book.id,
      chapter_number: @chapter.chapter_number
    }, as: :turbo_stream
    assert_response :success

    # Submit navigation
    patch navigation_path, params: {
      book_id: @book.id,
      chapter_number: @chapter.chapter_number,
      verse_number: @verse.verse_number
    }
    assert_response :redirect
    assert_match %r{/slideshow/#{@book.id}/#{@chapter.chapter_number}/#{@verse.verse_number}}, response.redirect_url
  end

  # Turbo Stream format tests
  test "should respond to turbo_stream format for select_book" do
    get select_book_navigation_url(book_id: @book.id), as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should respond to turbo_stream format for select_chapter" do
    get select_chapter_navigation_url(book_id: @book.id, chapter_number: @chapter.chapter_number), as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end
end
