class NavigationController < ApplicationController
  before_action :load_navigation_data, except: [ :close ]

  def show
  end

  def update
    book_id = params[:book_id] || params.dig(:navigation, :book_id)
    chapter_number = params[:chapter_number] || params.dig(:navigation, :chapter_number)
    verse_number = params[:verse_number] || params.dig(:navigation, :verse_number)

    if book_id.present? && chapter_number.present? && verse_number.present?
      redirect_to bible_slideshow_path(book_id, chapter_number, verse_number)
    else
      render :show
    end
  end

  def select_book
    @book_id = params[:book_id]
    @book = Book.find_by(id: @book_id)
    if @book.nil?
      @book = Book.first
    end
    @chapters = @book.chapters.by_number

    @chapter = @book.chapters.find_by(chapter_number: 1)
    @chapter_number = @chapter.chapter_number if @chapter
    @verses = @chapter&.verses&.by_number || []

    respond_to do |format|
      format.turbo_stream
    end
  end

  def select_chapter
    @book_id = params[:book_id]
    @chapter_number = params[:chapter_number]
    @book = Book.find_by(id: @book_id)
    if @book.nil?
      @book = Book.first
    end
    @chapter = @book.chapters.find_by(chapter_number: @chapter_number)
    @verses = @chapter&.verses&.by_number || []
    @chapters = @book.chapters.by_number

    respond_to do |format|
      format.turbo_stream
    end
  end

  def close
    render turbo_stream: turbo_stream.update("navigation-modal", "")
  end

  private

  def load_navigation_data
    @book_id = params[:book_id]
    @chapter_number = params[:chapter_number]
    @verse_number = params[:verse_number]

    # Cache all books data for selectors
    @all_books = Rails.cache.fetch("all_books_with_chapters", expires_in: 6.hours) do
      Book.by_name.includes(:chapters).all
    end

    if @book_id.present?
      @book = Book.find_by(id: @book_id)
      if @book.nil?
        @book = Book.first
      end
      @chapters = @book.chapters.by_number

      if @chapter_number.present?
        @chapter = @book.chapters.find_by(chapter_number: @chapter_number)
        @verses = @chapter&.verses&.by_number || []
      end
    end

    # Set default values for form
    @navigation_data = {
      book_id: @book_id,
      chapter_number: @chapter_number,
      verse_number: @verse_number
    }
  end
end
