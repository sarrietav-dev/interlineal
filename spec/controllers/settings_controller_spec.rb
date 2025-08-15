require "rails_helper"

RSpec.describe SettingsController, type: :controller do
  let(:verse) { create(:verse) }

  describe "GET #show" do
    it "renders settings modal" do
      get :show
      expect(response).to render_template(:show)
    end

    it "loads interlinear config and settings" do
      get :show
      expect(assigns(:interlinear_config)).to be_a(InterlinearConfig)
      expect(assigns(:settings)).to include("show_greek" => true, "show_spanish" => true)
    end

    it "creates config for session if none exists" do
      expect {
        get :show
      }.to change(InterlinearConfig, :count).by(1)

      config = assigns(:interlinear_config)
      expect(config.session_id).to eq(session.id.to_s)
    end

    it "uses existing config for session" do
      existing_config = create(:interlinear_config, session_id: session.id.to_s, show_greek: false)

      expect {
        get :show
      }.not_to change(InterlinearConfig, :count)

      expect(assigns(:interlinear_config)).to eq(existing_config)
      expect(assigns(:settings)["show_greek"]).to be false
    end
  end

  describe "PATCH #update" do
    let(:config) { create(:interlinear_config, session_id: session.id.to_s) }
    let(:valid_params) do
      {
        show_greek: "1",
        show_hebrew: "0",
        show_spanish: "1",
        show_strongs: "1",
        show_grammar: "0",
        show_pronunciation: "1",
        show_word_order: "0",
        primary_language: "greek",
        secondary_language: "hebrew",
        element_order: "2",
        greek_font_size: "120",
        spanish_font_size: "110",
        card_padding: "110",
        card_spacing: "90",
        card_theme: "compact",
        verse_id: verse.id
      }
    end

    before { config }

    context "with valid parameters" do
      it "updates interlinear config" do
        patch :update, params: valid_params
        config.reload

        expect(config.show_greek).to be true
        expect(config.show_hebrew).to be false
        expect(config.show_pronunciation).to be true
        expect(config.primary_language).to eq("greek")
        expect(config.secondary_language).to eq("hebrew")
        expect(config.element_order).to eq(2)
        expect(config.greek_font_size).to eq(120)
        expect(config.spanish_font_size).to eq(110)
        expect(config.card_padding).to eq(110)
        expect(config.card_spacing).to eq(90)
        expect(config.card_theme).to eq("compact")
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
        expect(response).to have_http_status(:redirect)
      end

      it "updates assigned settings hash" do
        patch :update, params: valid_params
        expect(assigns(:settings)["show_greek"]).to be true
        expect(assigns(:settings)["primary_language"]).to eq("greek")
        expect(assigns(:settings)["greek_font_size"]).to eq(120)
      end
    end

    context "with invalid parameters" do
      it "handles missing parameters gracefully" do
        patch :update, params: { verse_id: verse.id }
        expect(response).to have_http_status(:redirect)
      end

      it "handles invalid font size values" do
        expect {
          patch :update, params: valid_params.merge(greek_font_size: "250") # over max
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "handles invalid language combinations" do
        expect {
          patch :update, params: valid_params.merge(
            primary_language: "greek",
            secondary_language: "greek"
          )
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "PATCH #reset" do
    let!(:config) { create(:interlinear_config,
                          session_id: session.id.to_s,
                          show_greek: false,
                          show_spanish: false,
                          primary_language: "hebrew",
                          greek_font_size: 150,
                          card_theme: "spacious") }

    it "resets interlinear config to default values" do
      patch :reset, format: :turbo_stream
      config.reload

      expect(config.show_greek).to be true
      expect(config.show_spanish).to be true
      expect(config.primary_language).to eq("spanish")
      expect(config.secondary_language).to eq("greek")
      expect(config.element_order).to eq(1)
      expect(config.greek_font_size).to eq(100)
      expect(config.card_theme).to eq("default")
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
      expect(response).to have_http_status(:redirect)
    end

    it "updates assigned settings hash" do
      patch :reset, format: :turbo_stream
      expect(assigns(:settings)["show_greek"]).to be true
      expect(assigns(:settings)["primary_language"]).to eq("spanish")
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
    describe "#load_settings" do
      it "loads interlinear config and settings" do
        controller.send(:load_settings)
        expect(assigns(:interlinear_config)).to be_a(InterlinearConfig)
        expect(assigns(:settings)).to be_a(Hash)
        expect(assigns(:settings)).to include("show_greek", "primary_language", "greek_font_size")
      end
    end

    describe "#current_verse_words" do
      let(:word) { create(:word, verse: verse) }

      context "with verse_id parameter" do
        it "returns words for specified verse" do
          word
          controller.instance_variable_set(:@verse_id, verse.id)
      result = controller.send(:current_verse_words)
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
