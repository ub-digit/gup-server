class AddIndexesToTables2 < ActiveRecord::Migration
  def change
    add_index :publication_versions, :created_by
    add_index :publication_versions, :updated_by
  end
end
