class CreateInterlinearConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :interlinear_configs do |t|
      # Display settings (carried over from current session-based system)
      t.boolean :show_greek, default: true
      t.boolean :show_hebrew, default: true
      t.boolean :show_spanish, default: true
      t.boolean :show_strongs, default: true
      t.boolean :show_grammar, default: true
      t.boolean :show_pronunciation, default: false
      t.boolean :show_word_order, default: false

      # New layout and ordering settings
      t.string :primary_language, default: 'spanish' # spanish, greek, hebrew
      t.string :secondary_language, default: 'greek' # spanish, greek, hebrew
      t.integer :element_order, default: 1 # 1=primary->secondary->spanish, 2=spanish->primary->secondary, etc

      # Font size settings (as percentages, 100 = default)
      t.integer :greek_font_size, default: 100
      t.integer :hebrew_font_size, default: 100
      t.integer :spanish_font_size, default: 100
      t.integer :strongs_font_size, default: 100
      t.integer :grammar_font_size, default: 100
      t.integer :pronunciation_font_size, default: 100

      # Card appearance settings
      t.integer :card_padding, default: 100 # percentage of default padding
      t.integer :card_spacing, default: 100 # percentage of default spacing between cards
      t.string :card_theme, default: 'default' # default, compact, spacious

      # User identification (session-based for now, could be user-based later)
      t.string :session_id
      t.string :name, default: 'Default Configuration'

      t.timestamps
    end

    add_index :interlinear_configs, :session_id
  end
end
