class AddIndicesForEndnoteTables < ActiveRecord::Migration
  def change
    add_index :endnote_files, :username
    add_index :endnote_records, :publication_id
    add_index :endnote_records, :checksum
    add_index :endnote_file_records, :endnote_file_id
    add_index :endnote_file_records, :endnote_record_id
  end
end
