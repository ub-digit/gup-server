class AddPositionToPublicationLinks < ActiveRecord::Migration
  def change
    add_column :publication_links, :position, :integer
  end
end
