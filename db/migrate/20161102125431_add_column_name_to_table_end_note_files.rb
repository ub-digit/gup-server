class AddColumnNameToTableEndNoteFiles < ActiveRecord::Migration
  def change
    add_column :end_note_files, :name, :text
  end
end
