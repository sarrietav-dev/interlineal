namespace :data do
  desc "Copy data from nt.db to Rails database"
  task copy_nt_data: :environment do
    puts "Copying data from nt.db to Rails database..."

    # Connect to Rails database
    db_path = Rails.configuration.database_configuration[Rails.env]["database"]

    # Use SQLite to copy data directly
    system("sqlite3 #{db_path} << 'EOF'
      -- Attach the source database
      ATTACH 'nt.db' AS source;

      -- Copy books
      INSERT INTO books (name, abbreviation, testament, created_at)
      SELECT name, abbreviation, testament, created_at FROM source.books;

      -- Copy chapters
      INSERT INTO chapters (book_id, chapter_number, created_at)
      SELECT book_id, chapter_number, created_at FROM source.chapters;

      -- Copy verses
      INSERT INTO verses (chapter_id, verse_number, spanish_text, created_at)
      SELECT chapter_id, verse_number, spanish_text, created_at FROM source.verses;

      -- Copy words (without foreign key constraints)
      INSERT INTO words (verse_id, word_order, strong_number, greek_word, greek_grammar, spanish_translation, created_at)
      SELECT verse_id, word_order, strong_number, greek_word, greek_grammar, spanish_translation, created_at FROM source.words;

      -- Copy strongs (only those with valid strong_number)
      INSERT INTO strongs (strong_number, greek_word, pronunciation, definition, definition2, part_of_speech, derivation, rv1909_definition, rv1909_word_count, created_at, language)
      SELECT strong_number, greek_word, pronunciation, definition, definition2, part_of_speech, derivation, rv1909_definition, rv1909_word_count, created_at, 'greek' FROM source.strongs WHERE strong_number IS NOT NULL AND strong_number != '';

      -- Detach the source database
      DETACH source;
    EOF")

    puts "Data copy completed!"

    # Update word language field based on Strong's number
    puts "Updating word languages..."
    ActiveRecord::Base.connection.execute("
      UPDATE words
      SET language = CASE
        WHEN strong_number LIKE 'H%' THEN 'hebrew'
        WHEN strong_number LIKE 'G%' THEN 'greek'
        ELSE 'unknown'
      END
    ")

    # Move Hebrew words to hebrew_word field
    puts "Moving Hebrew words..."
    ActiveRecord::Base.connection.execute("
      UPDATE words
      SET hebrew_word = greek_word, greek_word = NULL
      WHERE language = 'hebrew'
    ")

    # Move Hebrew grammar to hebrew_grammar field
    ActiveRecord::Base.connection.execute("
      UPDATE words
      SET hebrew_grammar = greek_grammar, greek_grammar = NULL
      WHERE language = 'hebrew'
    ")

    puts "Data migration completed successfully!"
  end
end
