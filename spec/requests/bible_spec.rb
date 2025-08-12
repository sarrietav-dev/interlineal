require "rails_helper"

RSpec.describe "Bible", type: :request do
  let(:book) { create(:book, name: "John", abbreviation: "Jn") }
  let(:chapter) { create(:chapter, book: book, chapter_number: 3) }
  let(:verse) { create(:verse, chapter: chapter, verse_number: 16, spanish_text: "Porque de tal manera amó Dios al mundo") }

  before do
    book
    chapter
    verse
  end

  describe "GET /" do
    it "redirects to first verse" do
      get "/"
      expect(response).to redirect_to(bible_verse_path(book.id, chapter.chapter_number, verse.verse_number, locale: I18n.locale))
    end

    context "when no books exist" do
      before { Book.destroy_all }

      it "renders empty state" do
        get "/"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("No hay datos bíblicos disponibles")
      end
    end
  end

  describe "GET /books/:book_id" do
    it "redirects to first chapter" do
      get "/books/#{book.id}"
      expect(response).to redirect_to(bible_chapter_path(book.id, chapter.chapter_number, locale: I18n.locale))
    end

    context "when book has no chapters" do
      before { Chapter.destroy_all }

      it "renders book empty state" do
        get "/books/#{book.id}"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("No hay capítulos disponibles")
      end
    end

    context "when book doesn't exist" do
      it "redirects to root with error" do
        get "/books/999"
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Book not found")
      end
    end
  end

  describe "GET /books/:book_id/chapters/:chapter_number" do
    it "renders chapter view" do
      get "/books/#{book.id}/chapters/#{chapter.chapter_number}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("John 3")
    end

    it "includes verse content" do
      get "/books/#{book.id}/chapters/#{chapter.chapter_number}"
      expect(response.body).to include("Porque de tal manera amó Dios al mundo")
    end

    context "when chapter doesn't exist" do
      it "redirects to book with error" do
        get "/books/#{book.id}/chapters/999"
        expect(response).to redirect_to(bible_book_path(book.id, locale: I18n.locale))
        expect(flash[:alert]).to eq("Chapter not found")
      end
    end
  end

  describe "GET /books/:book_id/chapters/:chapter_number/verses/:verse_number" do
    it "renders verse view" do
      get "/books/#{book.id}/chapters/#{chapter.chapter_number}/verses/#{verse.verse_number}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("John 3:16")
    end

    it "includes interlinear display" do
      word = create(:word, verse: verse, greek_word: "λόγος", spanish_translation: "palabra")
      get "/books/#{book.id}/chapters/#{chapter.chapter_number}/verses/#{verse.verse_number}"
      expect(response.body).to include("λόγος")
      expect(response.body).to include("palabra")
    end

    context "when verse doesn't exist" do
      it "redirects to chapter with error" do
        get "/books/#{book.id}/chapters/#{chapter.chapter_number}/verses/999"
        expect(response).to redirect_to(bible_chapter_path(book.id, chapter.chapter_number))
        expect(flash[:alert]).to eq("Verse not found")
      end
    end
  end

  describe "GET /books/:book_id/chapters/:chapter_number/verses/:verse_number/slideshow" do
    it "renders slideshow layout" do
      get "/books/#{book.id}/chapters/#{chapter.chapter_number}/verses/#{verse.verse_number}/slideshow"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("slideshow")
    end

    context "with Turbo-Frame header" do
      it "renders without layout" do
        get "/books/#{book.id}/chapters/#{chapter.chapter_number}/verses/#{verse.verse_number}/slideshow",
            headers: { "Turbo-Frame" => "slideshow-content" }
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("<html>")
      end
    end
  end

  describe "GET /books/:book_id/chapters/:chapter_number/verses/:verse_number/interlinear" do
    it "renders interlinear partial" do
      word = create(:word, verse: verse, greek_word: "λόγος", spanish_translation: "palabra")
      get "/books/#{book.id}/chapters/#{chapter.chapter_number}/verses/#{verse.verse_number}/interlinear"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("λόγος")
      expect(response.body).to include("palabra")
    end
  end

  describe "GET /search" do
    before do
      word = create(:word, verse: verse, greek_word: "λόγος", spanish_translation: "palabra")
    end

    it "finds verses by spanish text" do
      get "/search", params: { q: "amó" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("John 3:16")
    end

    it "finds verses by greek word" do
      get "/search", params: { q: "λόγος" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("John 3:16")
    end

    it "finds verses by strong number" do
      word = create(:word, verse: verse, strong_number: "G26")
      get "/search", params: { q: "G26" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("John 3:16")
    end

    context "with short query" do
      it "returns empty results" do
        get "/search", params: { q: "a" }
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("John 3:16")
      end
    end

    context "with empty query" do
      it "returns empty results" do
        get "/search", params: { q: "" }
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("John 3:16")
      end
    end
  end

  describe "GET /strong/:strong_number" do
    let(:strong) { create(:strong, strong_number: "G26", definition: "word; saying") }

    before do
      word = create(:word, verse: verse, strong: strong)
    end

    it "renders strong definition" do
      get "/strong/#{strong.strong_number}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("G26")
      expect(response.body).to include("word; saying")
    end

    it "includes verses with this word" do
      get "/strong/#{strong.strong_number}"
      expect(response.body).to include("John 3:16")
    end

    context "when strong doesn't exist" do
      it "renders without strong data" do
        get "/strong/G999"
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("G999")
      end
    end
  end
end
