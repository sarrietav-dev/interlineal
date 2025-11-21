require "test_helper"

class BibleSearchFlowTest < ActionDispatch::IntegrationTest
  test "user can search for verses in Spanish" do
    # User searches for "Dios"
    get bible_search_url, params: { q: "Dios" }
    assert_response :success

    # Results should be present
    results = assigns(:results)
    assert_not_nil results
    assert results.any? { |v| v.spanish_text&.include?("Dios") }
  end

  test "user can search for Greek words" do
    # User searches for Greek word
    get bible_search_url, params: { q: "λόγος" }
    assert_response :success

    results = assigns(:results)
    assert_not_nil results
  end

  test "user can search for Hebrew words" do
    # User searches for Hebrew word
    get bible_search_url, params: { q: "אֱלֹהִים" }
    assert_response :success

    results = assigns(:results)
    assert_not_nil results
  end

  test "search handles special characters safely" do
    # Test SQL injection prevention
    dangerous_queries = [
      "'; DROP TABLE verses; --",
      "\" OR 1=1 --",
      "<script>alert('xss')</script>",
      "../../../etc/passwd"
    ]

    dangerous_queries.each do |query|
      get bible_search_url, params: { q: query }
      assert_response :success
      # Should not raise errors or expose vulnerabilities
    end
  end

  test "search with empty query returns no results" do
    get bible_search_url, params: { q: "" }
    assert_response :success
    assert_equal [], assigns(:results)
  end

  test "search with short query returns no results" do
    get bible_search_url, params: { q: "a" }
    assert_response :success
    assert_equal [], assigns(:results)
  end

  test "user can navigate from search results to verse" do
    # Search first
    get bible_search_url, params: { q: "Verbo" }
    assert_response :success

    results = assigns(:results)
    return if results.empty?

    # Navigate to first result
    verse = results.first
    get bible_verse_url(verse.chapter.book, verse.chapter.chapter_number, verse.verse_number)
    assert_response :success
  end
end
