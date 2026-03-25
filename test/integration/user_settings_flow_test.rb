require "test_helper"

class UserSettingsFlowTest < ActionDispatch::IntegrationTest
  setup do
    @verse = verses(:john_1_1)
  end

  test "user can view and update display settings" do
    # User opens settings
    get settings_url
    assert_response :success
    assert_not_nil assigns(:settings)

    # User changes settings
    patch settings_url, params: {
      show_greek: "1",
      show_hebrew: "0",
      show_spanish: "1",
      show_strongs: "1",
      show_grammar: "0",
      show_pronunciation: "1",
      show_word_order: "1"
    }

    # Settings should persist in session
    assert_equal true, session[:word_display_settings]["show_greek"]
    assert_equal false, session[:word_display_settings]["show_hebrew"]
    assert_equal true, session[:word_display_settings]["show_pronunciation"]
    assert_equal true, session[:word_display_settings]["show_word_order"]
  end

  test "user settings persist across page visits" do
    # User sets custom settings
    patch settings_url, params: {
      show_greek: "0",
      show_pronunciation: "1"
    }

    # User navigates to a verse
    get bible_verse_url(@verse.chapter.book, @verse.chapter.chapter_number, @verse.verse_number)
    assert_response :success

    # Settings should still be in session
    assert_equal false, session[:word_display_settings]["show_greek"]
    assert_equal true, session[:word_display_settings]["show_pronunciation"]
  end

  test "user can reset settings to defaults" do
    # User sets custom settings
    patch settings_url, params: {
      show_greek: "0",
      show_hebrew: "0",
      show_pronunciation: "1",
      show_word_order: "1"
    }

    # Verify custom settings are set
    assert_equal false, session[:word_display_settings]["show_greek"]
    assert_equal true, session[:word_display_settings]["show_pronunciation"]

    # User resets settings
    patch reset_settings_url

    # Settings should be back to defaults
    default_settings = {
      "show_greek" => true,
      "show_hebrew" => true,
      "show_spanish" => true,
      "show_strongs" => true,
      "show_grammar" => true,
      "show_pronunciation" => false,
      "show_word_order" => false
    }

    assert_equal default_settings, session[:word_display_settings]
  end

  test "settings affect interlinear display" do
    # User views verse first
    get bible_verse_url(@verse.chapter.book, @verse.chapter.chapter_number, @verse.verse_number)
    assert_response :success

    # User updates settings with Turbo Stream
    patch settings_url(verse_id: @verse.id), params: {
      show_greek: "1",
      show_hebrew: "0"
    }, as: :turbo_stream

    assert_response :success
    assert_match /target="body"/, response.body
    assert_match /word-settings:updated/, response.body
    assert_match /localStorage\.setItem\('word_display_settings'/, response.body
  end
end
