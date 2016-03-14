class RemoveNotNullFormPublicationIdentifiers < ActiveRecord::Migration
  def change
  	change_column :publication_identifiers, :updated_at, :datetime, :null => true
  end
end
