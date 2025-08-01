class Chapter < ApplicationRecord
  # Associations
  belongs_to :book
  has_many :verses, dependent: :destroy
  has_many :words, through: :verses

  # Validations
  validates :chapter_number, presence: true, numericality: { greater_than: 0 }
  validates :chapter_number, uniqueness: { scope: :book_id }

  # Scopes
  scope :by_number, -> { order(:chapter_number) }
  scope :for_book, ->(book_id) { where(book_id: book_id) }

  # Instance methods
  def full_reference
    "#{book.name} #{chapter_number}"
  end

  def verse_count
    verses.count
  end

  def word_count
    words.count
  end

  def next_chapter
    book.chapters.where("chapter_number > ?", chapter_number).order(:chapter_number).first
  end

  def previous_chapter
    book.chapters.where("chapter_number < ?", chapter_number).order(:chapter_number).last
  end
end
