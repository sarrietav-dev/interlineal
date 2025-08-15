class InterlinearConfig < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :primary_language, inclusion: { in: %w[spanish greek hebrew] }
  validates :secondary_language, inclusion: { in: %w[spanish greek hebrew] }
  validates :element_order, inclusion: { in: 1..6 } # Different arrangements
  validates :card_theme, inclusion: { in: %w[default compact spacious] }

  # Font size validations (50% to 200% of default)
  validates :greek_font_size, inclusion: { in: 50..200 }
  validates :hebrew_font_size, inclusion: { in: 50..200 }
  validates :spanish_font_size, inclusion: { in: 50..200 }
  validates :strongs_font_size, inclusion: { in: 50..200 }
  validates :grammar_font_size, inclusion: { in: 50..200 }
  validates :pronunciation_font_size, inclusion: { in: 50..200 }

  # Card appearance validations (50% to 150% of default)
  validates :card_padding, inclusion: { in: 50..150 }
  validates :card_spacing, inclusion: { in: 50..150 }

  # Prevent having same primary and secondary language
  validate :different_primary_and_secondary_languages

  # Scopes
  scope :for_session, ->(session_id) { where(session_id: session_id) }
  scope :default_config, -> { where(session_id: nil).where(name: "Default Configuration") }

  # Class methods
  def self.for_session_or_default(session_id)
    session_id_string = session_id.to_s if session_id
    for_session(session_id_string).first || default_config.first || create_default_config(session_id_string)
  end

  def self.create_default_config(session_id = nil)
    create!(
      session_id: session_id,
      name: session_id ? "My Configuration" : "Default Configuration"
    )
  end

  # Instance methods
  def display_settings_hash
    {
      "show_greek" => show_greek,
      "show_hebrew" => show_hebrew,
      "show_spanish" => show_spanish,
      "show_strongs" => show_strongs,
      "show_grammar" => show_grammar,
      "show_pronunciation" => show_pronunciation,
      "show_word_order" => show_word_order
    }
  end

  def layout_settings_hash
    {
      "primary_language" => primary_language,
      "secondary_language" => secondary_language,
      "element_order" => element_order,
      "card_theme" => card_theme
    }
  end

  def font_settings_hash
    {
      "greek_font_size" => greek_font_size,
      "hebrew_font_size" => hebrew_font_size,
      "spanish_font_size" => spanish_font_size,
      "strongs_font_size" => strongs_font_size,
      "grammar_font_size" => grammar_font_size,
      "pronunciation_font_size" => pronunciation_font_size
    }
  end

  def appearance_settings_hash
    {
      "card_padding" => card_padding,
      "card_spacing" => card_spacing
    }
  end

  def complete_settings_hash
    display_settings_hash
      .merge(layout_settings_hash)
      .merge(font_settings_hash)
      .merge(appearance_settings_hash)
  end

  def element_order_name
    case element_order
    when 1 then "Primary → Secondary → Spanish"
    when 2 then "Spanish → Primary → Secondary"
    when 3 then "Primary → Spanish → Secondary"
    when 4 then "Secondary → Primary → Spanish"
    when 5 then "Spanish → Secondary → Primary"
    when 6 then "Secondary → Spanish → Primary"
    else "Unknown"
    end
  end

  def arranged_word_elements(word)
    # Return array of hashes with element info based on element_order
    primary = language_element_for(primary_language, word)
    secondary = language_element_for(secondary_language, word)
    spanish = language_element_for("spanish", word)

    case element_order
    when 1 then [ primary, secondary, spanish ].compact
    when 2 then [ spanish, primary, secondary ].compact
    when 3 then [ primary, spanish, secondary ].compact
    when 4 then [ secondary, primary, spanish ].compact
    when 5 then [ spanish, secondary, primary ].compact
    when 6 then [ secondary, spanish, primary ].compact
    else [ primary, secondary, spanish ].compact
    end
  end

  private

  def different_primary_and_secondary_languages
    if primary_language == secondary_language
      errors.add(:secondary_language, "cannot be the same as primary language")
    end
  end

  def language_element_for(language, word)
    case language
    when "greek"
      return nil unless show_greek && word.greek_word.present?
      {
        type: "greek",
        text: word.greek_word,
        color_class: "text-sky-300",
        font_size: greek_font_size
      }
    when "hebrew"
      return nil unless show_hebrew && word.hebrew_word.present?
      {
        type: "hebrew",
        text: word.hebrew_word,
        color_class: "text-orange-300",
        font_size: hebrew_font_size
      }
    when "spanish"
      return nil unless show_spanish
      {
        type: "spanish",
        text: word.spanish_translation.present? ? word.spanish_translation : "\u2014",
        color_class: word.spanish_translation.present? ? "text-white" : "text-gray-400",
        font_size: spanish_font_size
      }
    end
  end
end
