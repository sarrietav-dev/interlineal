namespace :verses do
  desc "Find and fix verses with problematic Bible translation lists"
  task fix_translation_lists: :environment do
    puts "Searching for verses with problematic Bible translation lists..."

    # The problematic text pattern to remove
    problematic_text = "(RV1960) Biblia Reina Valera 1960 Biblia Nueva Traducción Viviente Biblia Católica (Latinoamericana) La Biblia Textual 3a Edicion Biblia Serafín de Ausejo 1975 Biblia Reina Valera Gómez (2023) Biblia Traducción en Lenguaje Actual Biblia de las Americas 1997 Nueva Biblia de las Américas 2005 Biblia Torres Amat 1825 La Biblia del Oso  RV 1569 Biblia Kadosh Israelita Mesiánica Biblia Nueva Versión Internacional 2022 Biblia Reina Valera Antigua 1602 (Biblia del Cántaro) Biblia Reina Valera 1862 Biblia Reina Valera 1865 Biblia Reina Valera 1909 Biblia Reina Valera 1977 Biblia Reina Valera Actualizada 1989 Biblia Reina Valera 1990 (Adventista del Séptimo Día) Biblia Reina Valera 1995 Biblia Reina Valera 2000 Biblia Traducción en Lenguaje Actual Interconfesional Biblia de Jerusalem 3-Edicion Biblia Reina Valera Contemporanea Biblia Universidad de Jerusalem Biblia Versión Israelita Nazarena 2011 Biblia al día 1989 Biblia Castilian 2003 Biblia del Siglo de Oro La Nueva Biblia Latinoamericana de Hoy Nueva Biblia Española (1975) Biblia de nuestro Pueblo Biblia Nacar-Colunga Biblia El Libro del Pueblo de Dios Biblia Septuaginta al Español Biblia Jünemann Septuaginta en español Biblia de Jerusalen Biblia Version Moderna (1929) La Palabra (versión hispanoamericana) Nueva Biblia de los Hispanos Biblia Palabra de Dios para Todos Biblia Dios habla hoy Biblia Spanish Sagradas Escrituras Biblia Nueva Versión Internacional 2017 Biblia de los Testigos de Jehová (Traducción del Nuevo Mundo) La Torah Biblia Brit Xadasha Judia Ortodoxa (Nuevo Testamento) Biblia Castellano Antiguo (Nuevo Testamento) Biblia Lenguaje Sencillo (Nuevo Testamento) Biblia EUNSA (Nuevo Testamento) Biblia Peshita (Nuevo Testamento) Biblia Arcas-Fernandez (Nuevo Testamento) Biblia Pablo Besson (Nuevo Testamento) Biblia Scio de San Miguel (Solo los Evangelios) Biblia DuTillet - Solo Mateo - Hebreo Biblia de Israel (Solo Genesis) Dios Habla Hoy Versión Española La Biblia Traducción Interconfesional (versión española) Biblia Reina Valera 2020 Biblia del Jubileo 2000 La Biblia Hispanoamericana (Traducción Interconfesional) Dios habla hoy 1994 PC Dios habla hoy con Deuterocanónicos Versión Española Dios habla hoy 1994 DK Dios habla Hoy Estándar Nueva Versión Internacional 2019 (simplificada - Nuevo Testamento) Nueva Biblia Viva Palabra de Dios para ti 2022 Versión Biblia Libre Biblia Reina Valera Actualizada 2015 La Palabra (versión española) Biblia Martin Nieto Segun el Texto Bizantino 2005 NT Traducción Contemporánea de la Biblia Biblia Lenguaje Básico Biblica® Open Nueva Biblia Viva 2008 Gloss Spanish"

    # Find verses that contain the problematic text
    problematic_verses = Verse.joins(chapter: :book)
                              .where("spanish_text LIKE ?", "%#{problematic_text}%")

    puts "Found #{problematic_verses.count} verses with problematic text"

    if problematic_verses.count > 0
      puts "\nFixing all verses..."
      fixed_count = 0

      problematic_verses.find_each(batch_size: 1000) do |verse|
        original_text = verse.spanish_text
        cleaned_text = original_text.gsub(problematic_text, "").strip

        if cleaned_text != original_text
          verse.update!(spanish_text: cleaned_text)
          fixed_count += 1

          # Show progress every 1000 verses
          if fixed_count % 1000 == 0
            puts "  Fixed #{fixed_count} verses so far..."
          end
        end
      end

      puts "\nFixed #{fixed_count} verses total"
    else
      puts "No problematic verses found"
    end
  end

  desc "Fix all verses by removing Bible translation lists (efficient batch processing)"
  task fix_all_verses: :environment do
    puts "Starting to fix all verses by removing Bible translation lists..."

    # The problematic text pattern to remove
    problematic_text = "(RV1960) Biblia Reina Valera 1960 Biblia Nueva Traducción Viviente Biblia Católica (Latinoamericana) La Biblia Textual 3a Edicion Biblia Serafín de Ausejo 1975 Biblia Reina Valera Gómez (2023) Biblia Traducción en Lenguaje Actual Biblia de las Americas 1997 Nueva Biblia de las Américas 2005 Biblia Torres Amat 1825 La Biblia del Oso  RV 1569 Biblia Kadosh Israelita Mesiánica Biblia Nueva Versión Internacional 2022 Biblia Reina Valera Antigua 1602 (Biblia del Cántaro) Biblia Reina Valera 1862 Biblia Reina Valera 1865 Biblia Reina Valera 1909 Biblia Reina Valera 1977 Biblia Reina Valera Actualizada 1989 Biblia Reina Valera 1990 (Adventista del Séptimo Día) Biblia Reina Valera 1995 Biblia Reina Valera 2000 Biblia Traducción en Lenguaje Actual Interconfesional Biblia de Jerusalem 3-Edicion Biblia Reina Valera Contemporanea Biblia Universidad de Jerusalem Biblia Versión Israelita Nazarena 2011 Biblia al día 1989 Biblia Castilian 2003 Biblia del Siglo de Oro La Nueva Biblia Latinoamericana de Hoy Nueva Biblia Española (1975) Biblia de nuestro Pueblo Biblia Nacar-Colunga Biblia El Libro del Pueblo de Dios Biblia Septuaginta al Español Biblia Jünemann Septuaginta en español Biblia de Jerusalen Biblia Version Moderna (1929) La Palabra (versión hispanoamericana) Nueva Biblia de los Hispanos Biblia Palabra de Dios para Todos Biblia Dios habla hoy Biblia Spanish Sagradas Escrituras Biblia Nueva Versión Internacional 2017 Biblia de los Testigos de Jehová (Traducción del Nuevo Mundo) La Torah Biblia Brit Xadasha Judia Ortodoxa (Nuevo Testamento) Biblia Castellano Antiguo (Nuevo Testamento) Biblia Lenguaje Sencillo (Nuevo Testamento) Biblia EUNSA (Nuevo Testamento) Biblia Peshita (Nuevo Testamento) Biblia Arcas-Fernandez (Nuevo Testamento) Biblia Pablo Besson (Nuevo Testamento) Biblia Scio de San Miguel (Solo los Evangelios) Biblia DuTillet - Solo Mateo - Hebreo Biblia de Israel (Solo Genesis) Dios Habla Hoy Versión Española La Biblia Traducción Interconfesional (versión española) Biblia Reina Valera 2020 Biblia del Jubileo 2000 La Biblia Hispanoamericana (Traducción Interconfesional) Dios habla hoy 1994 PC Dios habla hoy con Deuterocanónicos Versión Española Dios habla hoy 1994 DK Dios habla Hoy Estándar Nueva Versión Internacional 2019 (simplificada - Nuevo Testamento) Nueva Biblia Viva Palabra de Dios para ti 2022 Versión Biblia Libre Biblia Reina Valera Actualizada 2015 La Palabra (versión española) Biblia Martin Nieto Segun el Texto Bizantino 2005 NT Traducción Contemporánea de la Biblia Biblia Lenguaje Básico Biblica® Open Nueva Biblia Viva 2008 Gloss Spanish"

    total_verses = Verse.count
    puts "Total verses in database: #{total_verses}"

    # Process all verses in batches
    fixed_count = 0
    batch_size = 1000

    Verse.find_in_batches(batch_size: batch_size) do |batch|
      batch.each do |verse|
        original_text = verse.spanish_text
        cleaned_text = original_text.gsub(problematic_text, "").strip

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
