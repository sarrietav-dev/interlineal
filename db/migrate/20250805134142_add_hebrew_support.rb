class AddHebrewSupport < ActiveRecord::Migration[8.0]
  def change
    # Add Hebrew support to strongs table
    add_column :strongs, :hebrew_word, :text
    add_column :strongs, :language, :text

    # Add Hebrew support to words table
    add_column :words, :hebrew_word, :text
    add_column :words, :hebrew_grammar, :text
    add_column :words, :language, :text

    # Add indexes for Hebrew fields
    add_index :strongs, :language, name: "idx_strongs_language"
    add_index :words, :hebrew_word, name: "idx_words_hebrew_word"
    add_index :words, :language, name: "idx_words_language"
  end
end
