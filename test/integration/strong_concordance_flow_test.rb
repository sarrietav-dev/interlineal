require "test_helper"

class StrongConcordanceFlowTest < ActionDispatch::IntegrationTest
  setup do
    @strong = strongs(:g2316)
  end

  test "user can view Strong's definition" do
    get strong_definition_url(strong_number: @strong.strong_number)
    assert_response :success

    strong_result = assigns(:strong)
    assert_not_nil strong_result
    assert_equal @strong.strong_number, strong_result.strong_number
  end

  test "user can see verses containing Strong's word" do
    get strong_definition_url(strong_number: @strong.strong_number)
    assert_response :success

    verses_with_word = assigns(:verses_with_word)
    assert_not_nil verses_with_word
  end

  test "user can navigate from Strong's to verse" do
    get strong_definition_url(strong_number: @strong.strong_number)
    assert_response :success

    verses_with_word = assigns(:verses_with_word)
    return if verses_with_word.empty?

    # Navigate to first verse containing this word
    verse = verses_with_word.first
    get bible_verse_url(verse.chapter.book, verse.chapter.chapter_number, verse.verse_number)
    assert_response :success
  end

  test "handles non-existent Strong's number gracefully" do
    get strong_definition_url(strong_number: "99999")
    assert_response :success

    strong_result = assigns(:strong)
    assert_nil strong_result
  end

  test "user can access both Greek and Hebrew Strong's" do
    # Test Greek Strong's
    greek_strong = strongs(:g2316)
    get strong_definition_url(strong_number: greek_strong.strong_number)
    assert_response :success
    assert_equal "greek", assigns(:strong).language

    # Test Hebrew Strong's
    hebrew_strong = strongs(:h430)
    get strong_definition_url(strong_number: hebrew_strong.strong_number)
    assert_response :success
    assert_equal "hebrew", assigns(:strong).language
  end
end
