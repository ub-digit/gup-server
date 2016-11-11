class ChangeColumnsOfEndnoteRecord < ActiveRecord::Migration
  def change
    remove_column :endnote_files, :deleted_at
    remove_column :endnote_records, :deleted_at
    add_column :endnote_records, :doi, :text
    add_column :endnote_records, :rec_number, :integer
    add_column :endnote_records, :db_id, :text
  end
end
