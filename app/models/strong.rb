class Strong < ApplicationRecord
  # Associations
  has_many :words, foreign_key: :strong_number, primary_key: :strong_number

  # Validations
  validates :strong_number, presence: true, uniqueness: true
  validates :greek_word, presence: true, unless: :hebrew_word?
  validates :hebrew_word, presence: true, unless: :greek_word?

  # Scopes
  scope :by_number, -> { order(:strong_number) }
  scope :with_definitions, -> { where.not(definition: [ nil, "" ]) }
  scope :by_part_of_speech, ->(pos) { where(part_of_speech: pos) }
  scope :greek, -> { where(language: "greek") }
  scope :hebrew, -> { where(language: "hebrew") }

  # Instance methods
  def display_number
    if hebrew_word.present?
      "H#{strong_number}"
    else
      "G#{strong_number}"
    end
  end

  def full_definition
    parts = []
    parts << definition if definition.present?
    parts << definition2 if definition2.present?
    parts.join("; ")
  end

  def word_count
    words.count
  end

  def verses_with_this_word
    words.includes(verse: { chapter: :book }).map(&:verse).uniq
  end

  def searchable_text
    [
      greek_word,
      hebrew_word,
      pronunciation,
      definition,
      definition2,
      part_of_speech,
      derivation,
      rv1909_definition
    ].compact.join(" ")
  end

  def language
    if hebrew_word.present?
      "hebrew"
    elsif greek_word.present?
      "greek"
    else
      super
    end
  end
end
