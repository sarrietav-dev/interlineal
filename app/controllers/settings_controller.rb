class SettingsController < ApplicationController
  before_action :load_settings

  def show
  end

  def update
    @verse_id = params.dig(:settings, :verse_id)

    # Get or create InterlinearConfig for current session
    @interlinear_config = InterlinearConfig.for_session_or_default(session.id)

    # Permit both display and layout/font settings
    config_params = params.permit(
      :show_greek, :show_hebrew, :show_spanish, :show_strongs,
      :show_grammar, :show_pronunciation, :show_word_order,
      :primary_language, :secondary_language, :element_order,
      :greek_font_size, :hebrew_font_size, :spanish_font_size,
      :strongs_font_size, :grammar_font_size, :pronunciation_font_size,
      :card_padding, :card_spacing, :card_theme
    ).to_h

    # Transform boolean values
    boolean_fields = %w[show_greek show_hebrew show_spanish show_strongs show_grammar show_pronunciation show_word_order]
    boolean_fields.each do |field|
      config_params[field] = config_params[field] == "1" || config_params[field] == "true" if config_params.key?(field)
    end

    # Transform numeric values
    numeric_fields = %w[element_order greek_font_size hebrew_font_size spanish_font_size strongs_font_size grammar_font_size pronunciation_font_size card_padding card_spacing]
    numeric_fields.each do |field|
      config_params[field] = config_params[field].to_i if config_params.key?(field)
    end

    # Update the config
    @interlinear_config.update!(config_params)
    @settings = @interlinear_config.complete_settings_hash

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("settings-modal", ""),
          turbo_stream.update("interlinear-display",
            render_to_string(partial: "bible/interlinear_words",
                           locals: { words: current_verse_words,
                                   settings: @settings,
                                   config: @interlinear_config }))
        ]
      end
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def reset
    # Reset to default configuration
    @interlinear_config = InterlinearConfig.for_session_or_default(session.id)
    @interlinear_config.update!(
      show_greek: true,
      show_hebrew: true,
      show_spanish: true,
      show_strongs: true,
      show_grammar: true,
      show_pronunciation: false,
      show_word_order: false,
      primary_language: "spanish",
      secondary_language: "greek",
      element_order: 1,
      greek_font_size: 100,
      hebrew_font_size: 100,
      spanish_font_size: 100,
      strongs_font_size: 100,
      grammar_font_size: 100,
      pronunciation_font_size: 100,
      card_padding: 100,
      card_spacing: 100,
      card_theme: "default"
    )
    @settings = @interlinear_config.complete_settings_hash

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("settings-form",
            render_to_string(partial: "settings/form", locals: { config: @interlinear_config })),
          turbo_stream.update("interlinear-display",
            render_to_string(partial: "bible/interlinear_words",
                           locals: { words: current_verse_words,
                                   settings: @settings,
                                   config: @interlinear_config }))
        ]
      end
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def close
    render turbo_stream: turbo_stream.update("settings-modal", "")
  end

  private

  def load_settings
    @interlinear_config = InterlinearConfig.for_session_or_default(session.id)
    @settings = @interlinear_config.complete_settings_hash
  end

  def current_verse_words
    verse_id = @verse_id || params.dig(:settings, :verse_id) || params[:verse_id]

    if verse_id.present?
      verse = Verse.find_by(id: verse_id)
      verse&.words_with_strongs || []
    elsif request.referer&.match(/verses\/(\d+)/)
      verse = Verse.find_by(id: $1)
      verse&.words_with_strongs || []
    else
      []
    end
  end
end
