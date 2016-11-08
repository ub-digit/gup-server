class RefactorEndnoteFile < ActiveRecord::Migration

  def change
    drop_table :end_note_items
    drop_table :end_note_files

    create_table :endnote_files do |t|
      t.text :name
      t.text :username
      t.text :xml
      t.timestamps null: false
      t.datetime :deleted_at
    end

    create_table :endnote_records do |t|
      t.integer :publication_id
      t.text :checksum
      t.text :username
      t.timestamps null: false
      t.datetime :deleted_at

    end

    create_table :endnote_file_records do |t|
      t.integer :endnote_file_id
      t.integer :endnote_record_id
      t.integer :position
      t.timestamps null: false
    end

  end
end
