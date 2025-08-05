class CreateInitialTables < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.text :name, null: false
      t.text :abbreviation
      t.text :testament
      t.datetime :created_at, precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    end

    create_table :chapters do |t|
      t.integer :book_id
      t.integer :chapter_number
      t.datetime :created_at, precision: nil, default: -> { "CURRENT_TIMESTAMP" }
      t.index [:book_id, :chapter_number], unique: true, name: "idx_chapters_book_chapter"
      t.index [:book_id], name: "idx_chapters_book"
    end

    create_table :strongs do |t|
      t.text :strong_number, null: false
      t.text :greek_word
      t.text :hebrew_word
      t.text :pronunciation
      t.text :definition
      t.text :definition2
      t.text :part_of_speech
      t.text :derivation
      t.text :rv1909_definition
      t.text :rv1909_word_count
      t.text :language
      t.datetime :created_at, precision: nil, default: -> { "CURRENT_TIMESTAMP" }
      t.index :strong_number, unique: true, name: "idx_strongs_number"
      t.index :definition, name: "idx_strongs_definition"
      t.index :definition2, name: "idx_strongs_definition2"
      t.index :language, name: "idx_strongs_language"
    end

    create_table :verses do |t|
      t.integer :chapter_id
      t.integer :verse_number
      t.text :spanish_text
      t.datetime :created_at, precision: nil, default: -> { "CURRENT_TIMESTAMP" }
      t.index [:chapter_id, :verse_number], unique: true, name: "idx_verses_chapter_verse"
      t.index [:chapter_id], name: "idx_verses_chapter"
      t.index :spanish_text, name: "idx_verses_spanish_text"
    end

    create_table :words do |t|
      t.integer :verse_id
      t.integer :word_order
      t.text :strong_number
      t.text :greek_word
      t.text :hebrew_word
      t.text :greek_grammar
      t.text :hebrew_grammar
      t.text :spanish_translation
      t.text :language
      t.datetime :created_at, precision: nil, default: -> { "CURRENT_TIMESTAMP" }
      t.index [:verse_id, :word_order], name: "idx_words_verse_order"
      t.index [:verse_id], name: "idx_words_verse_id"
      t.index :strong_number, name: "idx_words_strong"
      t.index :greek_word, name: "idx_words_greek_word"
      t.index :hebrew_word, name: "idx_words_hebrew_word"
      t.index :spanish_translation, name: "idx_words_spanish_translation"
      t.index :language, name: "idx_words_language"
    end

    add_foreign_key :chapters, :books
    add_foreign_key :verses, :chapters
    add_foreign_key :words, :verses
  end
end
