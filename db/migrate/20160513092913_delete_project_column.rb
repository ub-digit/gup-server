class DeleteProjectColumn < ActiveRecord::Migration
  def change
    remove_column :publication_versions, :project
  end
end
