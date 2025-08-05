class SettingsController < ApplicationController
  before_action :load_settings

  def show
  end

  def update
    @verse_id = params.dig(:settings, :verse_id)

    new_settings = params.permit(
      :show_greek, :show_spanish, :show_strongs,
      :show_grammar, :show_pronunciation, :show_word_order
    ).to_h.transform_values { |v| v == "1" || v == "true" }

    session[:word_display_settings] = new_settings

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("settings-modal", ""),
          turbo_stream.update("interlinear-display",
            render_to_string(partial: "bible/interlinear_words",
                           locals: { words: current_verse_words,
                                   settings: @settings }))
        ]
      end
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def reset
    session[:word_display_settings] = default_settings

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("settings-form",
            render_to_string(partial: "settings/form", locals: { settings: @settings })),
          turbo_stream.update("interlinear-display",
            render_to_string(partial: "bible/interlinear_words",
                           locals: { words: current_verse_words,
                                   settings: @settings }))
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
    @settings = if session[:word_display_settings].is_a?(Hash)
      default_settings.merge(session[:word_display_settings])
    else
      default_settings
    end
  end

  def default_settings
    {
      "show_greek" => true,
      "show_spanish" => true,
      "show_strongs" => true,
      "show_grammar" => true,
      "show_pronunciation" => false,
      "show_word_order" => false
    }
  end

  def current_verse_words
    verse_id = @verse_id || params.dig(:settings, :verse_id) || params[:verse_id]

    if verse_id.present?
      Verse.find(verse_id).words_with_strongs
    elsif request.referer&.match(/verses\/(\d+)/)
      Verse.find($1).words_with_strongs
    else
      []
    end
  end
end
