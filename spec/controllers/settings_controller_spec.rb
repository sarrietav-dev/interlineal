require "rails_helper"

RSpec.describe SettingsController, type: :controller do
  let(:verse) { create(:verse) }

  describe "GET #show" do
    it "renders settings modal" do
      get :show
      expect(response).to render_template(:show)
    end

    it "loads default settings" do
      get :show
      expect(assigns(:settings)).to include("show_greek" => true, "show_spanish" => true)
    end

    it "merges session settings" do
      session[:word_display_settings] = { "show_greek" => false }
      get :show
      expect(assigns(:settings)["show_greek"]).to be false
    end
  end

  describe "PATCH #update" do
    let(:valid_params) do
      {
        settings: {
          show_greek: "1",
          show_hebrew: "0",
          show_spanish: "1",
          show_strongs: "1",
          show_grammar: "0",
          show_pronunciation: "0",
          show_word_order: "0"
        },
        verse_id: verse.id
      }
    end

    context "with valid parameters" do
      it "updates session settings" do
        patch :update, params: valid_params
        expect(session[:word_display_settings]["show_greek"]).to be true
        expect(session[:word_display_settings]["show_hebrew"]).to be false
      end

      it "responds with turbo stream" do
        patch :update, params: valid_params, format: :turbo_stream
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end

      it "updates settings modal and interlinear display" do
        patch :update, params: valid_params, format: :turbo_stream
        expect(response.body).to include("settings-modal")
        expect(response.body).to include("interlinear-display")
      end

      it "redirects back for HTML format" do
        patch :update, params: valid_params, format: :html
        expect(response).to redirect_back(fallback_location: root_path)
      end
    end

    context "with invalid parameters" do
      it "handles missing settings gracefully" do
        patch :update, params: { verse_id: verse.id }
        expect(response).to redirect_back(fallback_location: root_path)
      end
    end
  end

  describe "PATCH #reset" do
    before do
      session[:word_display_settings] = { "show_greek" => false, "show_spanish" => false }
    end

    it "resets to default settings" do
      patch :reset, format: :turbo_stream
      expect(session[:word_display_settings]["show_greek"]).to be true
      expect(session[:word_display_settings]["show_spanish"]).to be true
    end

    it "responds with turbo stream" do
      patch :reset, format: :turbo_stream
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    end

    it "updates settings form and interlinear display" do
      patch :reset, format: :turbo_stream
      expect(response.body).to include("settings-form")
      expect(response.body).to include("interlinear-display")
    end

    it "redirects back for HTML format" do
      patch :reset, format: :html
      expect(response).to redirect_back(fallback_location: root_path)
    end
  end

  describe "GET #close" do
    it "renders turbo stream to close modal" do
      get :close, format: :turbo_stream
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("settings-modal")
    end
  end

  describe "private methods" do
    describe "#default_settings" do
      it "returns default settings hash" do
        controller.send(:default_settings)
        expect(controller.send(:default_settings)).to include(
          "show_greek" => true,
          "show_hebrew" => true,
          "show_spanish" => true,
          "show_strongs" => true,
          "show_grammar" => true,
          "show_pronunciation" => false,
          "show_word_order" => false
        )
      end
    end

    describe "#current_verse_words" do
      let(:word) { create(:word, verse: verse) }

      context "with verse_id parameter" do
        it "returns words for specified verse" do
          word
          result = controller.send(:current_verse_words, verse_id: verse.id)
          expect(result).to include(word)
        end
      end

      context "with referer containing verse ID" do
        it "extracts verse ID from referer" do
          word
          request.env["HTTP_REFERER"] = "http://example.com/books/1/chapters/1/verses/16"
          result = controller.send(:current_verse_words)
          expect(result).to be_empty # No verse with ID 16 exists
        end
      end

      context "without verse context" do
        it "returns empty array" do
          result = controller.send(:current_verse_words)
          expect(result).to be_empty
        end
      end
    end
  end
end
