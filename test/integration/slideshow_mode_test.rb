require "test_helper"

class SlideshowModeTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:john)
    @chapter = chapters(:john_chapter_1)
    @verse = verses(:john_1_1)
  end

  test "user can view slideshow mode" do
    get bible_slideshow_url(@book, @chapter.chapter_number, @verse.verse_number)
    assert_response :success
    assert_not_nil assigns(:verse)
    assert_not_nil assigns(:words)
  end

  test "user can navigate in slideshow mode" do
    # Start at first verse
    get bible_slideshow_url(@book, @chapter.chapter_number, @verse.verse_number)
    assert_response :success

    # Navigate to next verse if available
    next_verse = @verse.next_verse
    if next_verse
      get bible_slideshow_url(@book, @chapter.chapter_number, next_verse.verse_number)
      assert_response :success
    end
  end

  test "slideshow mode loads navigation data" do
    get bible_slideshow_url(@book, @chapter.chapter_number, @verse.verse_number)
    assert_response :success

    # Should have navigation data loaded (at least one should be present)
    has_navigation = assigns(:prev_verse).present? ||
                     assigns(:next_verse).present? ||
                     assigns(:prev_chapter).present? ||
                     assigns(:next_chapter).present?

    # Note: John 1:1 might not have previous verse/chapter but should have next
    assert has_navigation || assigns(:next_verse).present?
  end

  test "user can access slideshow via navigation flow" do
    # User opens navigation
    get navigation_url(
      book_id: @book.id,
      chapter_number: @chapter.chapter_number,
      verse_number: @verse.verse_number
    )
    assert_response :success

    # User submits navigation form
    patch navigation_path, params: {
      book_id: @book.id,
      chapter_number: @chapter.chapter_number,
      verse_number: @verse.verse_number
    }

    assert_response :redirect
    # Should redirect to slideshow
    assert_match %r{/slideshow/}, response.redirect_url
  end

  test "slideshow respects user display settings" do
    # User sets custom display settings
    patch settings_url, params: {
      show_greek: "1",
      show_hebrew: "0",
      show_pronunciation: "1"
    }

    # User views slideshow
    get bible_slideshow_url(@book, @chapter.chapter_number, @verse.verse_number)
    assert_response :success

    # Settings should be available to the view
    settings = assigns(:settings)
    assert_not_nil settings
    assert_equal true, settings["show_greek"]
    assert_equal false, settings["show_hebrew"]
    assert_equal true, settings["show_pronunciation"]
  end

  test "slideshow works with Turbo Frame requests" do
    get bible_slideshow_url(@book, @chapter.chapter_number, @verse.verse_number),
        headers: { "Turbo-Frame" => "verse_content" }
    assert_response :success
  end
end
