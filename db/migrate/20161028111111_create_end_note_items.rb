class CreateEndNoteItems < ActiveRecord::Migration
  def change
    create_table :end_note_items do |t|
      t.integer :end_note_file_id
      t.integer :publication_id
      t.text :checksum
      t.timestamps null: false
    end
  end
end
