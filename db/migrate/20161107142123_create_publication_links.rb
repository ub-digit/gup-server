class CreatePublicationLinks < ActiveRecord::Migration
  def change
    drop_table :publication_links
    create_table :publication_links do |t|
      t.text :url
      t.references :publication_version, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
