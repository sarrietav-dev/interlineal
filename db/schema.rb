# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_21_145347) do
  create_table "books", force: :cascade do |t|
    t.text "name", null: false
    t.text "abbreviation"
    t.text "testament"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at"
  end

  create_table "chapters", force: :cascade do |t|
    t.integer "book_id"
    t.integer "chapter_number"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at"
    t.index ["book_id", "chapter_number"], name: "index_chapters_on_book_id_and_chapter_number"
    t.index ["book_id"], name: "index_chapters_on_book_id"
  end

  create_table "strongs", force: :cascade do |t|
    t.text "strong_number", null: false
    t.text "greek_word"
    t.text "hebrew_word"
    t.text "pronunciation"
    t.text "definition"
    t.text "definition2"
    t.text "part_of_speech"
    t.text "derivation"
    t.text "rv1909_definition"
    t.text "rv1909_word_count"
    t.text "language"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at"
    t.index ["definition"], name: "index_strongs_on_definition"
    t.index ["definition2"], name: "index_strongs_on_definition2"
    t.index ["language"], name: "idx_strongs_language"
    t.index ["strong_number"], name: "index_strongs_on_strong_number"
  end

  create_table "verses", force: :cascade do |t|
    t.integer "chapter_id"
    t.integer "verse_number"
    t.text "spanish_text"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at"
    t.index ["chapter_id", "verse_number"], name: "index_verses_on_chapter_id_and_verse_number"
    t.index ["chapter_id"], name: "index_verses_on_chapter_id"
    t.index ["spanish_text"], name: "index_verses_on_spanish_text"
  end

  create_table "words", force: :cascade do |t|
    t.integer "verse_id"
    t.integer "word_order"
    t.text "strong_number"
    t.text "greek_word"
    t.text "hebrew_word"
    t.text "greek_grammar"
    t.text "hebrew_grammar"
    t.text "spanish_translation"
    t.text "language"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at"
    t.index ["greek_word"], name: "index_words_on_greek_word"
    t.index ["hebrew_word"], name: "idx_words_hebrew_word"
    t.index ["language"], name: "idx_words_language"
    t.index ["spanish_translation"], name: "index_words_on_spanish_translation"
    t.index ["strong_number"], name: "index_words_on_strong_number"
    t.index ["verse_id", "word_order"], name: "index_words_on_verse_id_and_word_order"
    t.index ["verse_id"], name: "index_words_on_verse_id"
  end

  add_foreign_key "chapters", "books"
  add_foreign_key "verses", "chapters"
  add_foreign_key "words", "verses"
end
