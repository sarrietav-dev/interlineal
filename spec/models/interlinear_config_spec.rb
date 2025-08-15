require 'rails_helper'

RSpec.describe InterlinearConfig, type: :model do
  describe 'validations' do
    subject { build(:interlinear_config) }

    it 'validates presence of name' do
      config = build(:interlinear_config, name: nil)
      expect(config).not_to be_valid
      expect(config.errors[:name]).to include("can't be blank")
    end

    it 'validates inclusion of primary_language' do
      config = build(:interlinear_config, primary_language: 'invalid')
      expect(config).not_to be_valid
      expect(config.errors[:primary_language]).to include('is not included in the list')
    end

    it 'validates inclusion of secondary_language' do
      config = build(:interlinear_config, secondary_language: 'invalid')
      expect(config).not_to be_valid
      expect(config.errors[:secondary_language]).to include('is not included in the list')
    end

    it 'validates inclusion of element_order' do
      config = build(:interlinear_config, element_order: 0)
      expect(config).not_to be_valid
      expect(config.errors[:element_order]).to include('is not included in the list')

      config = build(:interlinear_config, element_order: 7)
      expect(config).not_to be_valid
      expect(config.errors[:element_order]).to include('is not included in the list')
    end

    it 'validates inclusion of card_theme' do
      config = build(:interlinear_config, card_theme: 'invalid')
      expect(config).not_to be_valid
      expect(config.errors[:card_theme]).to include('is not included in the list')
    end

    %w[greek_font_size hebrew_font_size spanish_font_size strongs_font_size grammar_font_size pronunciation_font_size].each do |font_field|
      it "validates inclusion of #{font_field}" do
        config = build(:interlinear_config, font_field => 40)
        expect(config).not_to be_valid
        expect(config.errors[font_field]).to include('is not included in the list')

        config = build(:interlinear_config, font_field => 250)
        expect(config).not_to be_valid
        expect(config.errors[font_field]).to include('is not included in the list')
      end
    end

    %w[card_padding card_spacing].each do |appearance_field|
      it "validates inclusion of #{appearance_field}" do
        config = build(:interlinear_config, appearance_field => 40)
        expect(config).not_to be_valid
        expect(config.errors[appearance_field]).to include('is not included in the list')

        config = build(:interlinear_config, appearance_field => 160)
        expect(config).not_to be_valid
        expect(config.errors[appearance_field]).to include('is not included in the list')
      end
    end

    describe 'different_primary_and_secondary_languages' do
      it 'is invalid when primary and secondary languages are the same' do
        config = build(:interlinear_config, primary_language: 'greek', secondary_language: 'greek')
        expect(config).not_to be_valid
        expect(config.errors[:secondary_language]).to include("cannot be the same as primary language")
      end

      it 'is valid when primary and secondary languages are different' do
        config = build(:interlinear_config, primary_language: 'greek', secondary_language: 'hebrew')
        expect(config).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:session_config) { create(:interlinear_config, session_id: 'test_session') }
    let!(:another_session_config) { create(:interlinear_config, session_id: 'another_session') }
    let!(:default_config) { create(:interlinear_config, session_id: nil, name: 'Default Configuration') }

    describe '.for_session' do
      it 'returns configs for specific session' do
        expect(InterlinearConfig.for_session('test_session')).to contain_exactly(session_config)
      end

      it 'returns empty for non-existent session' do
        expect(InterlinearConfig.for_session('non_existent')).to be_empty
      end
    end

    describe '.default_config' do
      it 'returns the default configuration' do
        expect(InterlinearConfig.default_config).to contain_exactly(default_config)
      end
    end
  end

  describe '.for_session_or_default' do
    context 'when session config exists' do
      let!(:session_config) { create(:interlinear_config, session_id: 'existing_session') }

      it 'returns the session config' do
        expect(InterlinearConfig.for_session_or_default('existing_session')).to eq(session_config)
      end
    end

    context 'when session config does not exist but default exists' do
      let!(:default_config) { create(:interlinear_config, session_id: nil, name: 'Default Configuration') }

      it 'returns the default config' do
        expect(InterlinearConfig.for_session_or_default('new_session')).to eq(default_config)
      end
    end

    context 'when neither session nor default config exist' do
      it 'creates and returns a new config for the session' do
        expect {
          result = InterlinearConfig.for_session_or_default('new_session')
          expect(result.session_id).to eq('new_session')
          expect(result.name).to eq('My Configuration')
          expect(result).to be_persisted
        }.to change(InterlinearConfig, :count).by(1)
      end
    end
  end

  describe '.create_default_config' do
    context 'with session_id' do
      it 'creates config with session_id and "My Configuration" name' do
        config = InterlinearConfig.create_default_config('test_session')
        expect(config.session_id).to eq('test_session')
        expect(config.name).to eq('My Configuration')
        expect(config).to be_persisted
      end
    end

    context 'without session_id' do
      it 'creates config with nil session_id and "Default Configuration" name' do
        config = InterlinearConfig.create_default_config(nil)
        expect(config.session_id).to be_nil
        expect(config.name).to eq('Default Configuration')
        expect(config).to be_persisted
      end
    end
  end

  describe 'instance methods' do
    let(:config) { create(:interlinear_config, :large_fonts, :compact_theme) }

    describe '#display_settings_hash' do
      it 'returns display settings as hash' do
        expected = {
          'show_greek' => true,
          'show_hebrew' => true,
          'show_spanish' => true,
          'show_strongs' => true,
          'show_grammar' => true,
          'show_pronunciation' => false,
          'show_word_order' => false
        }
        expect(config.display_settings_hash).to eq(expected)
      end
    end

    describe '#layout_settings_hash' do
      it 'returns layout settings as hash' do
        expected = {
          'primary_language' => 'spanish',
          'secondary_language' => 'greek',
          'element_order' => 1,
          'card_theme' => 'compact'
        }
        expect(config.layout_settings_hash).to eq(expected)
      end
    end

    describe '#font_settings_hash' do
      it 'returns font settings as hash' do
        expected = {
          'greek_font_size' => 150,
          'hebrew_font_size' => 150,
          'spanish_font_size' => 130,
          'strongs_font_size' => 100,
          'grammar_font_size' => 100,
          'pronunciation_font_size' => 100
        }
        expect(config.font_settings_hash).to eq(expected)
      end
    end

    describe '#appearance_settings_hash' do
      it 'returns appearance settings as hash' do
        expected = {
          'card_padding' => 80,
          'card_spacing' => 70
        }
        expect(config.appearance_settings_hash).to eq(expected)
      end
    end

    describe '#complete_settings_hash' do
      it 'returns all settings merged together' do
        result = config.complete_settings_hash
        expect(result).to include('show_greek' => true)
        expect(result).to include('primary_language' => 'spanish')
        expect(result).to include('greek_font_size' => 150)
        expect(result).to include('card_padding' => 80)
      end
    end

    describe '#element_order_name' do
      it 'returns human-readable name for element order 1' do
        config.element_order = 1
        expect(config.element_order_name).to eq("Primary → Secondary → Spanish")
      end

      it 'returns human-readable name for element order 2' do
        config.element_order = 2
        expect(config.element_order_name).to eq("Spanish → Primary → Secondary")
      end

      it 'returns human-readable name for element order 3' do
        config.element_order = 3
        expect(config.element_order_name).to eq("Primary → Spanish → Secondary")
      end

      it 'returns human-readable name for element order 4' do
        config.element_order = 4
        expect(config.element_order_name).to eq("Secondary → Primary → Spanish")
      end

      it 'returns human-readable name for element order 5' do
        config.element_order = 5
        expect(config.element_order_name).to eq("Spanish → Secondary → Primary")
      end

      it 'returns human-readable name for element order 6' do
        config.element_order = 6
        expect(config.element_order_name).to eq("Secondary → Spanish → Primary")
      end

      it 'returns "Unknown" for invalid element order' do
        config.element_order = 99
        expect(config.element_order_name).to eq("Unknown")
      end
    end

    describe '#arranged_word_elements' do
      let(:word) { create(:word, greek_word: 'λόγος', hebrew_word: 'דבר', spanish_translation: 'palabra') }
      let(:config) { create(:interlinear_config, primary_language: 'greek', secondary_language: 'hebrew', element_order: 1) }

      it 'returns elements in order 1 (Primary → Secondary → Spanish)' do
        elements = config.arranged_word_elements(word)

        expect(elements.length).to eq(3)
        expect(elements[0][:type]).to eq('greek')
        expect(elements[0][:text]).to eq('λόγος')
        expect(elements[1][:type]).to eq('hebrew')
        expect(elements[1][:text]).to eq('דבר')
        expect(elements[2][:type]).to eq('spanish')
        expect(elements[2][:text]).to eq('palabra')
      end

      it 'returns elements in order 2 (Spanish → Primary → Secondary)' do
        config.update!(element_order: 2)
        elements = config.arranged_word_elements(word)

        expect(elements.length).to eq(3)
        expect(elements[0][:type]).to eq('spanish')
        expect(elements[1][:type]).to eq('greek')
        expect(elements[2][:type]).to eq('hebrew')
      end

      it 'excludes elements when display is disabled' do
        config.update!(show_greek: false)
        elements = config.arranged_word_elements(word)

        expect(elements.length).to eq(2)
        expect(elements.map { |e| e[:type] }).not_to include('greek')
      end

      it 'excludes elements when word content is missing' do
        word.update!(greek_word: nil)
        elements = config.arranged_word_elements(word)

        expect(elements.length).to eq(2)
        expect(elements.map { |e| e[:type] }).not_to include('greek')
      end

      it 'includes font size in element data' do
        config.update!(greek_font_size: 120)
        elements = config.arranged_word_elements(word)
        greek_element = elements.find { |e| e[:type] == 'greek' }

        expect(greek_element[:font_size]).to eq(120)
      end

      it 'includes appropriate color classes' do
        elements = config.arranged_word_elements(word)

        greek_element = elements.find { |e| e[:type] == 'greek' }
        hebrew_element = elements.find { |e| e[:type] == 'hebrew' }
        spanish_element = elements.find { |e| e[:type] == 'spanish' }

        expect(greek_element[:color_class]).to eq('text-sky-300')
        expect(hebrew_element[:color_class]).to eq('text-orange-300')
        expect(spanish_element[:color_class]).to eq('text-white')
      end

      it 'shows "—" for missing Spanish translation with gray color' do
        word.update!(spanish_translation: nil)
        elements = config.arranged_word_elements(word)
        spanish_element = elements.find { |e| e[:type] == 'spanish' }

        expect(spanish_element[:text]).to eq('—')
        expect(spanish_element[:color_class]).to eq('text-gray-400')
      end
    end
  end

  describe 'traits' do
    describe ':compact_theme' do
      let(:config) { create(:interlinear_config, :compact_theme) }

      it 'sets compact theme properties' do
        expect(config.card_theme).to eq('compact')
        expect(config.card_padding).to eq(80)
        expect(config.card_spacing).to eq(70)
      end
    end

    describe ':spacious_theme' do
      let(:config) { create(:interlinear_config, :spacious_theme) }

      it 'sets spacious theme properties' do
        expect(config.card_theme).to eq('spacious')
        expect(config.card_padding).to eq(120)
        expect(config.card_spacing).to eq(130)
      end
    end

    describe ':large_fonts' do
      let(:config) { create(:interlinear_config, :large_fonts) }

      it 'sets large font sizes' do
        expect(config.greek_font_size).to eq(150)
        expect(config.hebrew_font_size).to eq(150)
        expect(config.spanish_font_size).to eq(130)
      end
    end

    describe ':minimal_display' do
      let(:config) { create(:interlinear_config, :minimal_display) }

      it 'shows only Spanish' do
        expect(config.show_spanish).to be true
        expect(config.show_greek).to be false
        expect(config.show_hebrew).to be false
        expect(config.show_strongs).to be false
        expect(config.show_grammar).to be false
        expect(config.show_pronunciation).to be false
        expect(config.show_word_order).to be false
      end
    end

    describe ':hebrew_primary' do
      let(:config) { create(:interlinear_config, :hebrew_primary) }

      it 'sets Hebrew as primary language' do
        expect(config.primary_language).to eq('hebrew')
        expect(config.secondary_language).to eq('spanish')
        expect(config.element_order).to eq(4)
      end
    end

    describe ':greek_primary' do
      let(:config) { create(:interlinear_config, :greek_primary) }

      it 'sets Greek as primary language' do
        expect(config.primary_language).to eq('greek')
        expect(config.secondary_language).to eq('hebrew')
        expect(config.element_order).to eq(1)
      end
    end
  end
end
