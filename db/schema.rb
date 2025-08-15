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

ActiveRecord::Schema[8.0].define(version: 2025_08_15_192346) do
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
  end

  create_table "interlinear_configs", force: :cascade do |t|
    t.boolean "show_greek", default: true
    t.boolean "show_hebrew", default: true
    t.boolean "show_spanish", default: true
    t.boolean "show_strongs", default: true
    t.boolean "show_grammar", default: true
    t.boolean "show_pronunciation", default: false
    t.boolean "show_word_order", default: false
    t.string "primary_language", default: "spanish"
    t.string "secondary_language", default: "greek"
    t.integer "element_order", default: 1
    t.integer "greek_font_size", default: 100
    t.integer "hebrew_font_size", default: 100
    t.integer "spanish_font_size", default: 100
    t.integer "strongs_font_size", default: 100
    t.integer "grammar_font_size", default: 100
    t.integer "pronunciation_font_size", default: 100
    t.integer "card_padding", default: 100
    t.integer "card_spacing", default: 100
    t.string "card_theme", default: "default"
    t.string "session_id"
    t.string "name", default: "Default Configuration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_interlinear_configs_on_session_id"
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
    t.index ["language"], name: "idx_strongs_language"
  end

  create_table "verses", force: :cascade do |t|
    t.integer "chapter_id"
    t.integer "verse_number"
    t.text "spanish_text"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at"
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
    t.index ["hebrew_word"], name: "idx_words_hebrew_word"
    t.index ["language"], name: "idx_words_language"
  end

  add_foreign_key "chapters", "books"
  add_foreign_key "verses", "chapters"
  add_foreign_key "words", "verses"
end
