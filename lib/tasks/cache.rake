namespace :cache do
  desc "Clear all Solid Cache entries"
  task clear: :environment do
    puts "Clearing all cache entries..."
    Rails.cache.clear
    puts "✓ Cache cleared successfully!"
  end

  desc "Clear verse-related cache entries"
  task clear_verses: :environment do
    puts "Clearing verse cache entries..."
    Verse.find_each do |verse|
      verse.touch
    end
    puts "✓ Verse caches invalidated!"
  end

  desc "Clear search cache entries"
  task clear_search: :environment do
    puts "Clearing search cache entries..."
    keys = Rails.cache.instance_variable_get(:@data)&.keys&.select { |k| k.to_s.include?('bible_search') }
    keys&.each { |key| Rails.cache.delete(key) }
    puts "✓ Search cache cleared!"
  end

  desc "Warm up frequently accessed caches"
  task warmup: :environment do
    puts "Warming up caches..."

    # Cache all books
    puts "- Caching books..."
    Rails.cache.fetch("all_books_with_chapters", expires_in: 12.hours) do
      Book.by_name.includes(:chapters).to_a
    end

    # Cache first verse of each book for quick access
    puts "- Caching sample verses..."
    Book.includes(chapters: :verses).find_each do |book|
      first_chapter = book.chapters.by_number.first
      next unless first_chapter

      first_verse = first_chapter.verses.by_number.first
      next unless first_verse

      # Cache navigation
      Rails.cache.fetch(['verse_navigation', first_verse.id, first_chapter.id], expires_in: 6.hours) do
        [nil, first_verse.next_verse, nil, first_chapter.next_chapter]
      end
    end

    puts "✓ Cache warmup complete!"
  end

  desc "Show cache statistics"
  task stats: :environment do
    puts "\n=== Solid Cache Statistics ==="

    if defined?(SolidCache::Entry)
      total_entries = SolidCache::Entry.count
      total_size = SolidCache::Entry.sum(:byte_size)

      puts "Total entries: #{total_entries}"
      puts "Total size: #{(total_size.to_f / 1024 / 1024).round(2)} MB"
      puts "Average entry size: #{(total_size.to_f / total_entries / 1024).round(2)} KB" if total_entries > 0

      # Group by key prefix
      puts "\nTop cache key prefixes:"
      entries_by_prefix = SolidCache::Entry.pluck(:key).map { |k| k.split(':').first }.tally
      entries_by_prefix.sort_by { |_, count| -count }.first(10).each do |prefix, count|
        puts "  #{prefix}: #{count} entries"
      end
    else
      puts "SolidCache::Entry model not found. Make sure Solid Cache is properly installed."
    end

    puts "\n"
  end
end
