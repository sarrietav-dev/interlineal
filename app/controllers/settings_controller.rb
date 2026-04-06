class SettingsController < ApplicationController
  before_action :load_settings

  def show
    # Cache settings modal for 1 hour - static form
    expires_in 1.hour, public: true, stale_while_revalidate: 6.hours
  end

  def update
    @verse_id = params.dig(:settings, :verse_id)

    new_settings = params.permit(
      :show_greek, :show_hebrew, :show_spanish, :show_strongs,
      :show_grammar, :show_pronunciation, :show_word_order
    ).to_h.transform_values { |v| v == "1" || v == "true" }

    session[:word_display_settings] = new_settings
    @settings = default_settings.merge(new_settings)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("settings-modal", ""),
          settings_sync_stream(@settings)
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
          settings_sync_stream(@settings)
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
      "show_hebrew" => true,
      "show_spanish" => true,
      "show_strongs" => true,
      "show_grammar" => true,
      "show_pronunciation" => false,
      "show_word_order" => false
    }
  end

  def settings_sync_stream(settings)
    # Keys are our hardcoded permit list; values are always booleans — safe to embed in script
    settings_json = settings.to_json
    script = %(<script>
      var s = #{settings_json};
      localStorage.setItem('word_display_settings', JSON.stringify(s));
      document.dispatchEvent(new CustomEvent('word-settings:updated', { detail: s }));
    </script>).html_safe
    turbo_stream.append("body", script)
  end
end
