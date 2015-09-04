class CreatePublicationIdentifiers < ActiveRecord::Migration
  def change
    create_table :publication_identifiers do |t|
      t.integer :publication_id
      t.text :identifier_code
      t.text :identifier_value
      t.timestamps null: false
    end
  end
end
