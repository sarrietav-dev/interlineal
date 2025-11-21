class BibleController < ApplicationController
  before_action :set_book, only: [ :show_book, :show_chapter, :show_verse, :slideshow ]
  before_action :set_chapter, only: [ :show_chapter, :show_verse, :slideshow ]
  before_action :set_verse, only: [ :show_verse, :slideshow ]

  # GET /
  def index
    # Cache all books data
    @books = Rails.cache.fetch("all_books_with_chapters", expires_in: 6.hours) do
      Book.includes(:chapters).by_name.to_a
    end

    @current_book = @books.first
    @current_chapter = @current_book&.chapters&.first
    @current_verse = @current_chapter&.verses&.first

    # Default to first verse of first chapter of first book
    if @current_verse
      redirect_to bible_verse_path(@current_book.id, @current_chapter.chapter_number, @current_verse.verse_number)
    else
      # Show empty state if no data
      render :empty_state
    end
  end

  # GET /books/:book_id
  def show_book
    @chapters = @book.chapters.by_number.includes(:verses)
    @current_chapter = @chapters.first

    if @current_chapter
      redirect_to bible_chapter_path(@book.id, @current_chapter.chapter_number)
    else
      render :book_empty
    end
  end

  # GET /books/:book_id/chapters/:chapter_number
  def show_chapter
    # Cache verse data for chapter
    @verses = Rails.cache.fetch("chapter_verses_#{@chapter.id}", expires_in: 6.hours) do
      @chapter.verses.by_number.includes(words: :strong).to_a
    end

    @current_verse = @verses.first
    @verse_count = @verses.count

    # Pagination for verses
    @page_size = params[:page_size]&.to_i || 10
    @page = params[:page]&.to_i || 1
    @paginated_verses = @verses.slice((@page - 1) * @page_size, @page_size)

    # Cache navigation data
    @prev_chapter = Rails.cache.fetch("prev_chapter_#{@chapter.id}", expires_in: 6.hours) do
      @chapter.previous_chapter
    end

    @next_chapter = Rails.cache.fetch("next_chapter_#{@chapter.id}", expires_in: 6.hours) do
      @chapter.next_chapter
    end

    @all_books = Rails.cache.fetch("all_books_with_chapters", expires_in: 6.hours) do
      Book.by_name.includes(:chapters).to_a
    end
  end

  # GET /books/:book_id/chapters/:chapter_number/verses/:verse_number
  def show_verse
    # Fragment caching in views handles the heavy lifting
    # Just load the data with proper eager loading
    @words = @verse.words.includes(:strong).order(:word_order).to_a
    @spanish_text = @verse.spanish_text

    # Navigation data - cache these as they're computed
    cache_key = ['verse_navigation', @verse.id, @chapter.id]
    @prev_verse, @next_verse, @prev_chapter, @next_chapter = Rails.cache.fetch(cache_key, expires_in: 6.hours) do
      prev_v = @verse.previous_verse
      next_v = @verse.next_verse
      prev_c = prev_v.nil? ? @chapter.previous_chapter : nil
      next_c = next_v.nil? ? @chapter.next_chapter : nil
      [prev_v, next_v, prev_c, next_c]
    end

    # Cache all books data for selectors
    @all_books = Rails.cache.fetch("all_books_with_chapters", expires_in: 12.hours) do
      Book.by_name.includes(:chapters).to_a
    end

    # For slideshow mode
    @slideshow_mode = params[:slideshow] == "true"

    # Load word display settings
    @word_display_settings = load_word_display_settings

    # Using Hotwire - no JSON API needed
  end

  # GET /slideshow/:book_id/:chapter_number/:verse_number
  def slideshow
    # Reuse data loading from show_verse
    @words = @verse.words.includes(:strong).order(:word_order).to_a
    @spanish_text = @verse.spanish_text

    # Reuse cached navigation
    cache_key = ['verse_navigation', @verse.id, @chapter.id]
    @prev_verse, @next_verse, @prev_chapter, @next_chapter = Rails.cache.fetch(cache_key, expires_in: 6.hours) do
      prev_v = @verse.previous_verse
      next_v = @verse.next_verse
      prev_c = prev_v.nil? ? @chapter.previous_chapter : nil
      next_c = next_v.nil? ? @chapter.next_chapter : nil
      [prev_v, next_v, prev_c, next_c]
    end

    # Load word display settings
    @word_display_settings = load_word_display_settings

    if turbo_frame_request?
      render partial: "slideshow_content", layout: false
    else
      render layout: false
    end
  end

  # GET /books/:book_id/chapters/:chapter_number/verses/:verse_number/interlinear
  def interlinear
    set_book
    set_chapter
    set_verse
    @words = @verse.words_with_strongs.by_order

    render partial: "interlinear_words", locals: { words: @words }
  end

  # GET /search
  def search
    @query = params[:q]&.strip

    if @query.present? && @query.length >= 2
      # Cache search results for 15 minutes
      cache_key = ['bible_search', @query, I18n.locale]
      @results = Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
        # Use sanitized SQL for LIKE queries to prevent SQL injection
        sanitized_query = ActiveRecord::Base.sanitize_sql_like(@query)

        # Search in Spanish text with eager loading
        spanish_results = Verse.joins(chapter: :book)
                              .where("verses.spanish_text LIKE ?", "%#{sanitized_query}%")
                              .includes(chapter: :book)
                              .limit(50)
                              .to_a

        # Search in Greek and Hebrew words
        greek_hebrew_results = Verse.joins(:words, chapter: :book)
                                  .where("words.greek_word LIKE ? OR words.hebrew_word LIKE ? OR words.spanish_translation LIKE ?",
                                         "%#{sanitized_query}%", "%#{sanitized_query}%", "%#{sanitized_query}%")
                                  .includes(chapter: :book)
                                  .distinct
                                  .limit(50)
                                  .to_a

        # Search in Strong's definitions with optimized query
        strong_results = Verse.joins(words: :strong, chapter: :book)
                             .where("strongs.definition LIKE ? OR strongs.definition2 LIKE ?",
                                    "%#{sanitized_query}%", "%#{sanitized_query}%")
                             .includes(chapter: :book)
                             .distinct
                             .limit(50)
                             .to_a

        # Combine and sort results
        (spanish_results + greek_hebrew_results + strong_results)
                    .uniq(&:id)
                    .sort_by { |verse| [ verse.book.name, verse.chapter.chapter_number, verse.verse_number ] }
      end
    else
      @results = []
    end

    @total_results = @results.count
  end

  # GET /strongs/:strong_number
  def strong_definition
    cache_key = ['strong_definition', params[:strong_number], I18n.locale]

    @strong, @verses_with_word = Rails.cache.fetch(cache_key, expires_in: 6.hours) do
      strong = Strong.find_by(strong_number: params[:strong_number])
      if strong
        verses = strong.verses_with_this_word.limit(20).to_a
        [strong, verses]
      else
        [nil, []]
      end
    end
  end

  private

  def set_book
    @book = Book.includes(:chapters).find(params[:book_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Book not found"
  end

  def set_chapter
    # Find the specific chapter
    @chapter = @book.chapters.find_by(chapter_number: params[:chapter_number])
    unless @chapter
      redirect_to bible_book_path(@book), alert: "Chapter not found"
    end

    # Preload verses for this specific chapter (for the verse dropdown in view)
    @chapter = Chapter.includes(:verses).find(@chapter.id)
  end

  def set_verse
    @verse = @chapter.verses.find_by(verse_number: params[:verse_number])
    unless @verse
      redirect_to bible_chapter_path(@book, @chapter.chapter_number), alert: "Verse not found"
    end
  end

  def load_word_display_settings
    default_settings = {
      "show_greek" => true,
      "show_hebrew" => true,
      "show_spanish" => true,
      "show_strongs" => true,
      "show_grammar" => true,
      "show_pronunciation" => false,
      "show_word_order" => false
    }

    if session[:word_display_settings].is_a?(Hash)
      default_settings.merge(session[:word_display_settings])
    else
      default_settings
    end
  end
end
