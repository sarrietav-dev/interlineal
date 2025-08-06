class Verse < ApplicationRecord
  # Associations
  belongs_to :chapter
  has_many :words, dependent: :destroy
  has_one :book, through: :chapter

  # Validations
  validates :verse_number, presence: true, numericality: { greater_than: 0 }
  validates :verse_number, uniqueness: { scope: :chapter_id }

  # Scopes
  scope :by_number, -> { order(:verse_number) }
  scope :for_chapter, ->(chapter_id) { where(chapter_id: chapter_id) }
  scope :with_spanish_text, -> { where.not(spanish_text: [ nil, "" ]) }

  # Instance methods
  def full_reference
    "#{chapter.full_reference}:#{verse_number}"
  end

  def word_count
    words.count
  end

  def next_verse
    chapter.verses.where("verse_number > ?", verse_number).order(:verse_number).first
  end

  def previous_verse
    chapter.verses.where("verse_number < ?", verse_number).order(:verse_number).last
  end

  def words_by_order
    words.order(:word_order)
  end

  def words_with_strongs
    words.includes(:strong).order(:word_order)
  end

  # Cache key for fragment caching
  def cache_key_with_version
    "#{cache_key}/#{updated_at.to_i}"
  end

  # Touch parent when verse changes to expire caches
  after_update :touch_chapter

  private

  def touch_chapter
    chapter.touch
  end
end
