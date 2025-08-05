namespace :data do
  desc "Clear existing data and migrate from nt.db"
  task clear_and_migrate: :environment do
    puts "Clearing existing data..."
    
    # Clear data in reverse order of dependencies
    Word.delete_all
    Verse.delete_all
    Chapter.delete_all
    Strong.delete_all
    Book.delete_all
    
    puts "Data cleared. Starting migration..."
    
    # Run the migration task
    Rake::Task['data:migrate_nt_data'].invoke
  end
end 