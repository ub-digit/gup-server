class CreateEndNoteFiles < ActiveRecord::Migration
  def change
    create_table :end_note_files do |t|
      t.text :username
      t.text :xml
      t.datetime :deleted_at
      t.timestamps null: false
    end
  end
end
