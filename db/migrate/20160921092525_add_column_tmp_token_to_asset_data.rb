class AddColumnTmpTokenToAssetData < ActiveRecord::Migration
  def change
    add_column :asset_data, :tmp_token, :text
  end
end
