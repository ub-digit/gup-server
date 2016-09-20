class AddColumnChecksumToAssetData < ActiveRecord::Migration
  def change
    add_column :asset_data, :checksum, :text
  end
end
