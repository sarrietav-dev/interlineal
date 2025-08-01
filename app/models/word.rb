class Word < ApplicationRecord
  # Associations
  belongs_to :verse
  belongs_to :strong, foreign_key: :strong_number, primary_key: :strong_number, optional: true
  has_one :chapter, through: :verse
  has_one :book, through: :chapter

  # Validations
  validates :word_order, presence: true, numericality: { greater_than: 0 }
  validates :word_order, uniqueness: { scope: :verse_id }

  # Scopes
  scope :by_order, -> { order(:word_order) }
  scope :for_verse, ->(verse_id) { where(verse_id: verse_id) }
  scope :with_strongs, -> { where.not(strong_number: [ nil, "" ]) }
  scope :with_greek, -> { where.not(greek_word: [ nil, "" ]) }
  scope :with_spanish, -> { where.not(spanish_translation: [ nil, "" ]) }

  # Instance methods
  def full_reference
    "#{verse.full_reference}:#{word_order}"
  end

  def display_greek
    greek_word.present? ? greek_word : "N/A"
  end

  def display_spanish
    spanish_translation.present? ? spanish_translation : "N/A"
  end

  def display_strong
    strong_number.present? ? "G#{strong_number}" : "N/A"
  end

  def has_strong_definition?
    strong.present?
  end

  def strong_definition
    strong&.full_definition
  end

  def searchable_text
    [
      greek_word,
      spanish_translation,
      greek_grammar,
      strong_number
    ].compact.join(" ")
  end
end
