class AddIndexForPublicationIdentifiers < ActiveRecord::Migration
  def change
    add_index :publication_identifiers, :identifier_code
    add_index :publication_identifiers, :identifier_value
  end
end
