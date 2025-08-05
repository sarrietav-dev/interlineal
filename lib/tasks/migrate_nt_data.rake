namespace :data do
  desc "Migrate data from nt.db to Rails database"
  task migrate_nt_data: :environment do
    puts "Starting data migration from nt.db..."

    # Connect to source database
    source_db = SQLite3::Database.new("nt.db")
    source_db.results_as_hash = true

    # Store ID mappings
    book_id_map = {}
    chapter_id_map = {}
    verse_id_map = {}

    # Migrate books
    puts "Migrating books..."
    books_count = 0
    source_db.execute("SELECT * FROM books ORDER BY id") do |row|
      book = Book.create!(
        name: row["name"],
        abbreviation: row["abbreviation"],
        testament: row["testament"]
      )
      book_id_map[row["id"]] = book.id
      books_count += 1
      print "." if books_count % 10 == 0
    end
    puts "\nMigrated #{books_count} books"

    # Migrate chapters
    puts "Migrating chapters..."
    chapters_count = 0
    source_db.execute("SELECT * FROM chapters ORDER BY book_id, chapter_number") do |row|
      new_book_id = book_id_map[row["book_id"]]
      book = Book.find(new_book_id)
      chapter = book.chapters.create!(
        chapter_number: row["chapter_number"]
      )
      chapter_id_map[row["id"]] = chapter.id
      chapters_count += 1
      print "." if chapters_count % 50 == 0
    end
    puts "\nMigrated #{chapters_count} chapters"

    # Migrate verses in batches
    puts "Migrating verses..."
    verses_count = 0
    batch_size = 1000
    offset = 0

    loop do
      verses_batch = source_db.execute("SELECT * FROM verses ORDER BY chapter_id, verse_number LIMIT #{batch_size} OFFSET #{offset}")
      break if verses_batch.empty?

      verses_batch.each do |row|
        new_chapter_id = chapter_id_map[row["chapter_id"]]
        chapter = Chapter.find(new_chapter_id)
        verse = chapter.verses.create!(
          verse_number: row["verse_number"],
          spanish_text: row["spanish_text"]
        )
        verse_id_map[row["id"]] = verse.id
        verses_count += 1
      end

      print "." if verses_count % 1000 == 0
      offset += batch_size
    end
    puts "\nMigrated #{verses_count} verses"

    # Skip Strong's migration for now - data is incomplete
    puts "Skipping Strong's migration (data incomplete)"

    # Migrate words in batches
    puts "Migrating words..."
    words_count = 0
    offset = 0

    loop do
      words_batch = source_db.execute("SELECT * FROM words ORDER BY verse_id, word_order LIMIT #{batch_size} OFFSET #{offset}")
      break if words_batch.empty?

      words_batch.each do |row|
        new_verse_id = verse_id_map[row["verse_id"]]
        verse = Verse.find(new_verse_id)

        # Determine language based on Strong's number
        language = if row["strong_number"]&.start_with?("H")
          "hebrew"
        elsif row["strong_number"]&.start_with?("G")
          "greek"
        else
          "unknown"
        end

        word = verse.words.create!(
          word_order: row["word_order"],
          strong_number: row["strong_number"],
          greek_word: language == "greek" ? row["greek_word"] : nil,
          hebrew_word: language == "hebrew" ? row["greek_word"] : nil, # The greek_word field contains Hebrew in this case
          greek_grammar: language == "greek" ? row["greek_grammar"] : nil,
          hebrew_grammar: language == "hebrew" ? row["greek_grammar"] : nil,
          spanish_translation: row["spanish_translation"],
          language: language
        )

        words_count += 1
      end

      print "." if words_count % 10000 == 0
      offset += batch_size
    end
    puts "\nMigrated #{words_count} words"

    source_db.close
    puts "Data migration completed successfully!"
  end
end
