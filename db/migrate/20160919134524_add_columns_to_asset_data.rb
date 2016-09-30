class AddColumnsToAssetData < ActiveRecord::Migration
  def change
    add_column :asset_data, :created_by, :text
    add_column :asset_data, :deleted_by, :text
  end
end
