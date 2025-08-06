class Book < ApplicationRecord
  # Associations
  has_many :chapters, dependent: :destroy
  has_many :verses, through: :chapters
  has_many :words, through: :verses

  # Validations
  validates :name, presence: true
  validates :abbreviation, presence: true
  validates :testament, presence: true, inclusion: { in: %w[OT NT] }

  # Scopes
  scope :new_testament, -> { where(testament: "NT") }
  scope :old_testament, -> { where(testament: "OT") }
  scope :by_name, -> { order(:id) }  # Changed from order(:name) to order(:id) for canonical order

  # Instance methods
  def full_name
    "#{name} (#{abbreviation})"
  end

  def chapter_count
    chapters.count
  end

  def verse_count
    verses.count
  end

  def word_count
    words.count
  end
end
