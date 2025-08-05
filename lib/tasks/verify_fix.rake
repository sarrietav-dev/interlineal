namespace :verses do
  desc "Verify that Bible translation lists have been removed from verses"
  task verify_fix: :environment do
    puts "Verifying that Bible translation lists have been removed..."

    # Check for any remaining instances of the problematic text
    problematic_text = "(RV1960) Biblia Reina Valera 1960"

    remaining_verses = Verse.where("spanish_text LIKE ?", "%#{problematic_text}%")

    if remaining_verses.count == 0
      puts "✅ SUCCESS: No verses found with the problematic Bible translation list"

      # Show a few sample verses to verify they look clean
      puts "\nSample verses after fix:"
      sample_verses = Verse.joins(chapter: :book).limit(5)
      sample_verses.each do |verse|
        book_name = verse.chapter.book.name
        chapter_num = verse.chapter.chapter_number
        verse_num = verse.verse_number
        text_preview = verse.spanish_text[0..100]
        puts "  #{book_name} #{chapter_num}:#{verse_num}: #{text_preview}..."
      end

    else
      puts "❌ WARNING: Found #{remaining_verses.count} verses still containing the problematic text"

      remaining_verses.limit(5).each do |verse|
        book_name = verse.chapter.book.name
        chapter_num = verse.chapter.chapter_number
        verse_num = verse.verse_number
        puts "  #{book_name} #{chapter_num}:#{verse_num}"
      end
    end
  end
end
