class CreateAssetData < ActiveRecord::Migration
  def change
    create_table :asset_data do |t|
      t.integer :publication_id
      t.text :name
      t.text :path
      t.text :content_type
      t.timestamps
      t.datetime :deleted_at
    end
  end
end
