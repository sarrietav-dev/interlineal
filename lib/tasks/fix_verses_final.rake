namespace :verses do
  desc "Final fix for verses with Bible translation lists - using targeted approach"
  task fix_verses_final: :environment do
    puts "Starting final fix for all verses..."

    total_verses = Verse.count
    puts "Total verses in database: #{total_verses}"

    # Process all verses in batches
    fixed_count = 0
    batch_size = 1000

    Verse.find_in_batches(batch_size: batch_size) do |batch|
      batch.each do |verse|
        original_text = verse.spanish_text

        # Remove the problematic text pattern
        cleaned_text = original_text

        # Remove the specific pattern that starts with (RV1960)
        if cleaned_text.include?("(RV1960)")
          # Find the start of the problematic text
          start_index = cleaned_text.index("(RV1960)")
          if start_index
            # Find the end of the problematic text (look for the end of the long list)
            # The problematic text ends with "Gloss Spanish"
            end_marker = "Gloss Spanish"
            end_index = cleaned_text.index(end_marker, start_index)

            if end_index
              # Remove the problematic text
              end_position = end_index + end_marker.length
              cleaned_text = cleaned_text[0...start_index] + cleaned_text[end_position..-1]
              cleaned_text = cleaned_text.strip
            else
              # If we can't find the end marker, just remove from (RV1960) to the end
              cleaned_text = cleaned_text[0...start_index].strip
            end
          end
        end

        if cleaned_text != original_text
          verse.update!(spanish_text: cleaned_text)
          fixed_count += 1
        end
      end

      puts "Processed batch, fixed #{fixed_count} verses so far..."
    end

    puts "\nCompleted! Fixed #{fixed_count} verses out of #{total_verses} total verses"
  end
end
