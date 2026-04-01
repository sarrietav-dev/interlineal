class EnsureUpdatedAtColumnsExist < ActiveRecord::Migration[8.0]
  TABLES = %i[books chapters verses words strongs].freeze

  def up
    TABLES.each do |table|
      add_updated_at_column(table) unless column_exists?(table, :updated_at)
      backfill_updated_at(table)
    end
  end

  def down
    TABLES.each do |table|
      remove_column(table, :updated_at) if column_exists?(table, :updated_at)
    end
  end

  private

  def add_updated_at_column(table)
    add_column table, :updated_at, :datetime, default: -> { "CURRENT_TIMESTAMP" }
  end

  def backfill_updated_at(table)
    execute <<~SQL.squish
      UPDATE #{table}
      SET updated_at = COALESCE(updated_at, created_at, CURRENT_TIMESTAMP)
      WHERE updated_at IS NULL
    SQL
  end
end
