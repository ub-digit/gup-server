class DropPublicationTypeField < ActiveRecord::Migration
  def change
    remove_column :publication_versions, :publication_type
  end
end
