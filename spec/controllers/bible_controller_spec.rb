require "rails_helper"

RSpec.describe BibleController, type: :controller do
  let(:book) { create(:book, name: "John", abbreviation: "Jn") }
  let(:chapter) { create(:chapter, book: book, chapter_number: 3) }
  let(:verse) { create(:verse, chapter: chapter, verse_number: 16, spanish_text: "Porque de tal manera amó Dios al mundo") }

  describe "GET #index" do
    context "when books exist" do
      before do
        book
        chapter
        verse
      end

      it "redirects to first verse" do
        get :index
        expect(response).to redirect_to(bible_verse_path(book.id, chapter.chapter_number, verse.verse_number))
      end
    end

    context "when no books exist" do
      it "renders empty state" do
        get :index
        expect(response).to render_template(:empty_state)
      end
    end
  end

  describe "GET #show_book" do
    context "when book exists with chapters" do
      before do
        book
        chapter
        verse
      end

      it "redirects to first chapter" do
        get :show_book, params: { book_id: book.id }
        expect(response).to redirect_to(bible_chapter_path(book.id, chapter.chapter_number))
      end
    end

    context "when book has no chapters" do
      it "renders book empty state" do
        get :show_book, params: { book_id: book.id }
        expect(response).to render_template(:book_empty)
      end
    end

    context "when book doesn't exist" do
      it "redirects to root with error" do
        get :show_book, params: { book_id: 999 }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Book not found")
      end
    end
  end

  describe "GET #show_chapter" do
    before do
      book
      chapter
      verse
    end

    it "renders chapter view" do
      get :show_chapter, params: { book_id: book.id, chapter_number: chapter.chapter_number }
      expect(response).to render_template(:show_chapter)
    end

    it "assigns verses" do
      get :show_chapter, params: { book_id: book.id, chapter_number: chapter.chapter_number }
      expect(assigns(:verses)).to include(verse)
    end

    it "assigns navigation data" do
      get :show_chapter, params: { book_id: book.id, chapter_number: chapter.chapter_number }
      expect(assigns(:current_verse)).to eq(verse)
      expect(assigns(:verse_count)).to eq(1)
    end

    context "when chapter doesn't exist" do
      it "redirects to book with error" do
        get :show_chapter, params: { book_id: book.id, chapter_number: 999 }
        expect(response).to redirect_to(bible_book_path(book.id))
        expect(flash[:alert]).to eq("Chapter not found")
      end
    end
  end

  describe "GET #show_verse" do
    before do
      book
      chapter
      verse
    end

    it "renders verse view" do
      get :show_verse, params: { book_id: book.id, chapter_number: chapter.chapter_number, verse_number: verse.verse_number }
      expect(response).to render_template(:show_verse)
    end

    it "assigns words" do
      word = create(:word, verse: verse)
      get :show_verse, params: { book_id: book.id, chapter_number: chapter.chapter_number, verse_number: verse.verse_number }
      expect(assigns(:words)).to include(word)
    end

    it "assigns navigation data" do
      get :show_verse, params: { book_id: book.id, chapter_number: chapter.chapter_number, verse_number: verse.verse_number }
      expect(assigns(:verse)).to eq(verse)
      expect(assigns(:spanish_text)).to eq(verse.spanish_text)
    end

    context "when verse doesn't exist" do
      it "redirects to chapter with error" do
        get :show_verse, params: { book_id: book.id, chapter_number: chapter.chapter_number, verse_number: 999 }
        expect(response).to redirect_to(bible_chapter_path(book.id, chapter.chapter_number))
        expect(flash[:alert]).to eq("Verse not found")
      end
    end
  end

  describe "GET #slideshow" do
    before do
      book
      chapter
      verse
    end

    it "renders slideshow layout" do
      get :slideshow, params: { book_id: book.id, chapter_number: chapter.chapter_number, verse_number: verse.verse_number }
      expect(response).to render_template(:slideshow)
    end

    it "renders without layout for turbo frame" do
      request.headers["Turbo-Frame"] = "slideshow-content"
      get :slideshow, params: { book_id: book.id, chapter_number: chapter.chapter_number, verse_number: verse.verse_number }
      expect(response).to render_template(partial: "_slideshow_content")
    end
  end

  describe "GET #interlinear" do
    before do
      book
      chapter
      verse
    end

    it "renders interlinear partial" do
      get :interlinear, params: { book_id: book.id, chapter_number: chapter.chapter_number, verse_number: verse.verse_number }
      expect(response).to render_template(partial: "_interlinear_words")
    end
  end

  describe "GET #search" do
    before do
      book
      chapter
      verse
    end

    context "with valid query" do
      it "finds verses by spanish text" do
        get :search, params: { q: "amó" }
        expect(assigns(:results)).to include(verse)
      end

      it "finds verses by greek word" do
        word = create(:word, verse: verse, greek_word: "λόγος")
        get :search, params: { q: "λόγος" }
        expect(assigns(:results)).to include(verse)
      end

      it "finds verses by strong number" do
        word = create(:word, verse: verse, strong_number: "G26")
        get :search, params: { q: "G26" }
        expect(assigns(:results)).to include(verse)
      end

      it "limits results to 50" do
        create_list(:verse, 60, chapter: chapter, spanish_text: "test")
        get :search, params: { q: "test" }
        expect(assigns(:results).length).to be <= 50
      end
    end

    context "with short query" do
      it "returns empty results" do
        get :search, params: { q: "a" }
        expect(assigns(:results)).to be_empty
      end
    end

    context "with empty query" do
      it "returns empty results" do
        get :search, params: { q: "" }
        expect(assigns(:results)).to be_empty
      end
    end
  end

  describe "GET #strong_definition" do
    let(:strong) { create(:strong, strong_number: "G26") }

    context "when strong exists" do
      before do
        strong
        word = create(:word, verse: verse, strong: strong)
      end

      it "assigns strong" do
        get :strong_definition, params: { strong_number: strong.strong_number }
        expect(assigns(:strong)).to eq(strong)
      end

      it "assigns verses with word" do
        get :strong_definition, params: { strong_number: strong.strong_number }
        expect(assigns(:verses_with_word)).to include(verse)
      end
    end

    context "when strong doesn't exist" do
      it "assigns nil strong" do
        get :strong_definition, params: { strong_number: "G999" }
        expect(assigns(:strong)).to be_nil
      end
    end
  end
end
