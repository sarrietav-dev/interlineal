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

ActiveRecord::Schema[8.0].define(version: 2025_08_05_134142) do
  create_table "books", force: :cascade do |t|
    t.text "name", null: false
    t.text "abbreviation"
    t.text "testament"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "chapters", force: :cascade do |t|
    t.integer "book_id"
    t.integer "chapter_number"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
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
    t.index ["language"], name: "idx_strongs_language"
  end

  create_table "verses", force: :cascade do |t|
    t.integer "chapter_id"
    t.integer "verse_number"
    t.text "spanish_text"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
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
    t.index ["hebrew_word"], name: "idx_words_hebrew_word"
    t.index ["language"], name: "idx_words_language"
  end

  add_foreign_key "chapters", "books"
  add_foreign_key "verses", "chapters"
  add_foreign_key "words", "verses"
end
