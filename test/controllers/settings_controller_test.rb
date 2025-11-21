require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @verse = verses(:john_1_1)
  end

  # Show action tests
  test "should get show" do
    get settings_url
    assert_response :success
    assert_not_nil assigns(:settings)
  end

  test "should load default settings" do
    get settings_url
    assert_response :success
    settings = assigns(:settings)
    assert_equal true, settings["show_greek"]
    assert_equal true, settings["show_hebrew"]
    assert_equal true, settings["show_spanish"]
    assert_equal true, settings["show_strongs"]
    assert_equal true, settings["show_grammar"]
    assert_equal false, settings["show_pronunciation"]
    assert_equal false, settings["show_word_order"]
  end

  test "should load settings from session if present" do
    # Set custom settings in session first
    custom_settings = {
      "show_greek" => false,
      "show_hebrew" => false,
      "show_pronunciation" => true
    }

    # Use patch to set session
    patch settings_url, params: {
      show_greek: "0",
      show_hebrew: "0",
      show_pronunciation: "1"
    }

    # Then get settings page
    get settings_url
    assert_response :success

    settings = assigns(:settings)
    # Should merge with defaults
    assert_equal false, settings["show_greek"]
    assert_equal false, settings["show_hebrew"]
    assert_equal true, settings["show_pronunciation"]
    # Default values should still be present
    assert_equal true, settings["show_spanish"]
  end

  # Update action tests
  test "should update settings" do
    patch settings_url, params: {
      show_greek: "1",
      show_hebrew: "0",
      show_spanish: "1",
      show_strongs: "0",
      show_grammar: "1",
      show_pronunciation: "1",
      show_word_order: "0"
    }

    # Check session was updated
    settings = session[:word_display_settings]
    assert_equal true, settings["show_greek"]
    assert_equal false, settings["show_hebrew"]
    assert_equal true, settings["show_spanish"]
    assert_equal false, settings["show_strongs"]
    assert_equal true, settings["show_grammar"]
    assert_equal true, settings["show_pronunciation"]
    assert_equal false, settings["show_word_order"]
  end

  test "should update settings with string true/false" do
    patch settings_url, params: {
      show_greek: "true",
      show_hebrew: "false"
    }

    settings = session[:word_display_settings]
    assert_equal true, settings["show_greek"]
    assert_equal false, settings["show_hebrew"]
  end

  test "should update settings and redirect for html format" do
    patch settings_url, params: {
      show_greek: "1"
    }

    assert_response :redirect
    # Will redirect back or to root with possible locale param
    assert_match %r{^http://www\.example\.com/}, response.redirect_url
  end

  test "should update settings and respond with turbo stream" do
    patch settings_url(verse_id: @verse.id), params: {
      show_greek: "1"
    }, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should update settings with verse_id in settings hash" do
    patch settings_url, params: {
      settings: {
        verse_id: @verse.id
      },
      show_greek: "1"
    }, as: :turbo_stream

    assert_response :success
  end

  # Reset action tests
  test "should reset settings to defaults" do
    # First set custom settings
    patch settings_url, params: {
      show_greek: "0",
      show_hebrew: "0",
      show_pronunciation: "1"
    }

    # Then reset
    patch reset_settings_url

    # Check settings are back to defaults
    settings = session[:word_display_settings]
    assert_equal true, settings["show_greek"]
    assert_equal true, settings["show_hebrew"]
    assert_equal false, settings["show_pronunciation"]
  end

  test "should reset settings and redirect for html format" do
    patch reset_settings_url
    assert_response :redirect
    # Will redirect back or to root with possible locale param
    assert_match %r{^http://www\.example\.com/}, response.redirect_url
  end

  test "should reset settings and respond with turbo stream" do
    patch reset_settings_url(verse_id: @verse.id), as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  # Close action tests
  test "should close settings modal" do
    get close_settings_url, as: :turbo_stream
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  # Integration with verse words
  test "should load verse words when verse_id provided" do
    patch settings_url(verse_id: @verse.id), params: {
      show_greek: "1"
    }, as: :turbo_stream

    assert_response :success
    # Response should contain the interlinear display update
    assert_match /interlinear-display/, response.body
  end

  test "should handle missing verse_id gracefully" do
    patch settings_url, params: {
      show_greek: "1"
    }, as: :turbo_stream

    assert_response :success
    # Should not raise error even without verse_id
  end

  # Session persistence tests
  test "settings should persist across requests" do
    # First request: set settings
    patch settings_url, params: {
      show_greek: "0",
      show_pronunciation: "1"
    }

    # Second request: check settings are loaded from session
    get settings_url
    settings = assigns(:settings)
    assert_equal false, settings["show_greek"]
    assert_equal true, settings["show_pronunciation"]
  end
end
