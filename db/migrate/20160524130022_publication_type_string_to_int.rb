class PublicationTypeStringToInt < ActiveRecord::Migration
  def change
    add_column :publication_versions, :publication_type_id, :integer
  end
end
