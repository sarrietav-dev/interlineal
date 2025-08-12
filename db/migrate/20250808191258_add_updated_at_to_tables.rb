class AddUpdatedAtToTables < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :updated_at, :datetime
    add_column :chapters, :updated_at, :datetime
    add_column :verses, :updated_at, :datetime
    add_column :words, :updated_at, :datetime
    add_column :strongs, :updated_at, :datetime

    # Update existing records to have updated_at set to created_at
    execute "UPDATE books SET updated_at = created_at WHERE updated_at IS NULL"
    execute "UPDATE chapters SET updated_at = created_at WHERE updated_at IS NULL"
    execute "UPDATE verses SET updated_at = created_at WHERE updated_at IS NULL"
    execute "UPDATE words SET updated_at = created_at WHERE updated_at IS NULL"
    execute "UPDATE strongs SET updated_at = created_at WHERE updated_at IS NULL"
  end
end
