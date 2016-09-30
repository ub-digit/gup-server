class ChangeAcceptedTypeInAssetData < ActiveRecord::Migration
  def change
    change_column :asset_data, :accepted, :text  
  end
end
