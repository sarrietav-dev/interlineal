class BibleController < ApplicationController
  before_action :set_book, only: [ :show_book, :show_chapter, :show_verse, :slideshow ]
  before_action :set_chapter, only: [ :show_chapter, :show_verse, :slideshow ]
  before_action :set_verse, only: [ :show_verse, :slideshow ]

  # GET /
  def index
    @books = Book.includes(:chapters).by_name
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
    @verses = @chapter.verses.by_number.includes(words: :strong)
    @current_verse = @verses.first
    @verse_count = @verses.count

    # Pagination for verses
    @page_size = params[:page_size]&.to_i || 10
    @page = params[:page]&.to_i || 1
    @paginated_verses = @verses.limit(@page_size).offset((@page - 1) * @page_size)

    # Navigation data
    @prev_chapter = @chapter.previous_chapter
    @next_chapter = @chapter.next_chapter
    @all_books = Book.by_name.includes(:chapters)
  end

  # GET /books/:book_id/chapters/:chapter_number/verses/:verse_number
  def show_verse
    @words = @verse.words_with_strongs.by_order
    @spanish_text = @verse.spanish_text

    # Navigation data
    @prev_verse = @verse.previous_verse
    @next_verse = @verse.next_verse
    @prev_chapter = @chapter.previous_chapter if @prev_verse.nil?
    @next_chapter = @chapter.next_chapter if @next_verse.nil?
    @all_books = Book.by_name.includes(:chapters)

    # For slideshow mode
    @slideshow_mode = params[:slideshow] == "true"

    # Load word display settings
    @word_display_settings = load_word_display_settings

    # Using Hotwire - no JSON API needed
  end

  # GET /slideshow/:book_id/:chapter_number/:verse_number
  def slideshow
    @words = @verse.words_with_strongs.by_order
    @spanish_text = @verse.spanish_text

    # Navigation for slideshow
    @prev_verse = @verse.previous_verse
    @next_verse = @verse.next_verse
    @prev_chapter = @chapter.previous_chapter if @prev_verse.nil?
    @next_chapter = @chapter.next_chapter if @next_verse.nil?

    render layout: false
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
    @results = []

    if @query.present? && @query.length >= 2
      # Search in Spanish text
      spanish_results = Verse.joins(:chapter, :book)
                            .where("spanish_text LIKE ?", "%#{@query}%")
                            .includes(:chapter, :book)
                            .limit(50)

      # Search in Greek words
      greek_results = Word.joins(verse: { chapter: :book })
                         .where("greek_word LIKE ? OR spanish_translation LIKE ?", "%#{@query}%", "%#{@query}%")
                         .includes(verse: { chapter: :book })
                         .limit(50)
                         .map(&:verse)
                         .uniq

      # Search in Strong's definitions
      strong_results = Strong.joins(words: { verse: { chapter: :book } })
                           .where("definition LIKE ? OR definition2 LIKE ?", "%#{@query}%", "%#{@query}%")
                           .includes(words: { verse: { chapter: :book } })
                           .limit(50)
                           .flat_map(&:verses_with_this_word)
                           .uniq

      @results = (spanish_results + greek_results + strong_results).uniq.sort_by do |verse|
        [ verse.book.name, verse.chapter.chapter_number, verse.verse_number ]
      end
    end

    @total_results = @results.count
  end

  # GET /strongs/:strong_number
  def strong_definition
    @strong = Strong.find_by(strong_number: params[:strong_number])

    if @strong
      @verses_with_word = @strong.verses_with_this_word.limit(20)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("strong-definition",
            render_to_string(partial: "strong_definition",
                           locals: { strong: @strong, verses: @verses_with_word }))
        end
        format.html do
          render partial: "strong_definition", locals: { strong: @strong, verses: @verses_with_word }
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("strong-definition",
            render_to_string(partial: "strong_not_found"))
        end
        format.html do
          render partial: "strong_not_found"
        end
      end
    end
  end

  private

  def set_book
    @book = Book.find(params[:book_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Book not found"
  end

  def set_chapter
    @chapter = @book.chapters.find_by(chapter_number: params[:chapter_number])
    unless @chapter
      redirect_to bible_book_path(@book), alert: "Chapter not found"
    end
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
