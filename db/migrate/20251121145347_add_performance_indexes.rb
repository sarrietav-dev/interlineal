class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  def change
    # Foreign key indexes for joins
    add_index :chapters, :book_id unless index_exists?(:chapters, :book_id)
    add_index :verses, :chapter_id unless index_exists?(:verses, :chapter_id)
    add_index :words, :verse_id unless index_exists?(:words, :verse_id)
    add_index :words, :strong_number unless index_exists?(:words, :strong_number)

    # Search performance indexes
    add_index :verses, :spanish_text unless index_exists?(:verses, :spanish_text)
    add_index :words, :greek_word unless index_exists?(:words, :greek_word)
    add_index :words, :spanish_translation unless index_exists?(:words, :spanish_translation)
    add_index :strongs, :strong_number unless index_exists?(:strongs, :strong_number)
    add_index :strongs, :definition unless index_exists?(:strongs, :definition)
    add_index :strongs, :definition2 unless index_exists?(:strongs, :definition2)

    # Composite indexes for common queries
    add_index :verses, [:chapter_id, :verse_number] unless index_exists?(:verses, [:chapter_id, :verse_number])
    add_index :chapters, [:book_id, :chapter_number] unless index_exists?(:chapters, [:book_id, :chapter_number])
    add_index :words, [:verse_id, :word_order] unless index_exists?(:words, [:verse_id, :word_order])
  end
end
