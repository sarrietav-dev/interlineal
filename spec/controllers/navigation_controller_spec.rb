require "rails_helper"

RSpec.describe NavigationController, type: :controller do
  let(:book) { create(:book, name: "John", abbreviation: "Jn") }
  let(:chapter) { create(:chapter, book: book, chapter_number: 3) }
  let(:verse) { create(:verse, chapter: chapter, verse_number: 16) }

  describe "GET #show" do
    before do
      book
      chapter
      verse
    end

    it "renders navigation modal" do
      get :show
      expect(response).to render_template(:show)
    end

    it "assigns navigation data" do
      get :show, params: { book_id: book.id, chapter_number: chapter.chapter_number, verse_number: verse.verse_number }
      expect(assigns(:book_id)).to eq(book.id.to_s)
      expect(assigns(:chapter_number)).to eq(chapter.chapter_number.to_s)
      expect(assigns(:verse_number)).to eq(verse.verse_number.to_s)
    end

    it "loads all books" do
      get :show
      expect(assigns(:all_books)).to include(book)
    end

    it "sets default book when book_id is invalid" do
      get :show, params: { book_id: 999 }
      expect(assigns(:book)).to eq(Book.first)
    end
  end

  describe "PATCH #update" do
    before do
      book
      chapter
      verse
    end

    context "with complete navigation parameters" do
      it "redirects to slideshow" do
        patch :update, params: {
          book_id: book.id,
          chapter_number: chapter.chapter_number,
          verse_number: verse.verse_number
        }
        expect(response).to redirect_to(bible_slideshow_path(book.id, chapter.chapter_number, verse.verse_number))
      end

      it "handles nested parameters" do
        patch :update, params: {
          navigation: {
            book_id: book.id,
            chapter_number: chapter.chapter_number,
            verse_number: verse.verse_number
          }
        }
        expect(response).to redirect_to(bible_slideshow_path(book.id, chapter.chapter_number, verse.verse_number))
      end
    end

    context "with incomplete parameters" do
      it "renders show template" do
        patch :update, params: { book_id: book.id }
        expect(response).to render_template(:show)
      end
    end
  end

  describe "GET #select_book" do
    before do
      book
      chapter
      verse
    end

    it "responds with turbo stream" do
      get :select_book, params: { book_id: book.id }, format: :turbo_stream
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "assigns book and chapters" do
      get :select_book, params: { book_id: book.id }, format: :turbo_stream
      expect(assigns(:book)).to eq(book)
      expect(assigns(:chapters)).to include(chapter)
    end

    it "sets default chapter" do
      get :select_book, params: { book_id: book.id }, format: :turbo_stream
      expect(assigns(:chapter)).to eq(chapter)
      expect(assigns(:chapter_number)).to eq(chapter.chapter_number)
    end

    it "assigns verses for default chapter" do
      get :select_book, params: { book_id: book.id }, format: :turbo_stream
      expect(assigns(:verses)).to include(verse)
    end

    context "with invalid book_id" do
      it "uses first book as fallback" do
        get :select_book, params: { book_id: 999 }, format: :turbo_stream
        expect(assigns(:book)).to eq(Book.first)
      end
    end
  end

  describe "GET #select_chapter" do
    before do
      book
      chapter
      verse
    end

    it "responds with turbo stream" do
      get :select_chapter, params: { book_id: book.id, chapter_number: chapter.chapter_number }, format: :turbo_stream
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "assigns book and chapter" do
      get :select_chapter, params: { book_id: book.id, chapter_number: chapter.chapter_number }, format: :turbo_stream
      expect(assigns(:book)).to eq(book)
      expect(assigns(:chapter)).to eq(chapter)
    end

    it "assigns verses for selected chapter" do
      get :select_chapter, params: { book_id: book.id, chapter_number: chapter.chapter_number }, format: :turbo_stream
      expect(assigns(:verses)).to include(verse)
    end

    it "assigns all chapters for book" do
      get :select_chapter, params: { book_id: book.id, chapter_number: chapter.chapter_number }, format: :turbo_stream
      expect(assigns(:chapters)).to include(chapter)
    end

    context "with invalid book_id" do
      it "uses first book as fallback" do
        get :select_chapter, params: { book_id: 999, chapter_number: 1 }, format: :turbo_stream
        expect(assigns(:book)).to eq(Book.first)
      end
    end
  end

  describe "GET #close" do
    it "renders turbo stream to close modal" do
      get :close, format: :turbo_stream
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("navigation-modal")
    end
  end

  describe "private methods" do
    describe "#load_navigation_data" do
      before do
        book
        chapter
        verse
      end

      it "sets navigation data from parameters" do
        controller.params = ActionController::Parameters.new(
          book_id: book.id.to_s,
          chapter_number: chapter.chapter_number.to_s,
          verse_number: verse.verse_number.to_s
        )
        controller.send(:load_navigation_data)
        expect(assigns(:book_id)).to eq(book.id.to_s)
        expect(assigns(:chapter_number)).to eq(chapter.chapter_number.to_s)
        expect(assigns(:verse_number)).to eq(verse.verse_number.to_s)
      end

      it "loads book and chapters when book_id present" do
        controller.params = ActionController::Parameters.new(book_id: book.id.to_s)
        controller.send(:load_navigation_data)
        expect(assigns(:book)).to eq(book)
        expect(assigns(:chapters)).to include(chapter)
      end

      it "loads chapter and verses when chapter_number present" do
        controller.params = ActionController::Parameters.new(
          book_id: book.id.to_s,
          chapter_number: chapter.chapter_number.to_s
        )
        controller.send(:load_navigation_data)
        expect(assigns(:chapter)).to eq(chapter)
        expect(assigns(:verses)).to include(verse)
      end

      it "sets navigation data hash" do
        controller.params = ActionController::Parameters.new(
          book_id: book.id.to_s,
          chapter_number: chapter.chapter_number.to_s,
          verse_number: verse.verse_number.to_s
        )
        controller.send(:load_navigation_data)
        expect(assigns(:navigation_data)).to include(
          book_id: book.id.to_s,
          chapter_number: chapter.chapter_number.to_s,
          verse_number: verse.verse_number.to_s
        )
      end
    end
  end
end
