class AddColumnAcceptedToAssesData < ActiveRecord::Migration
  def change
    add_column :asset_data, :accepted, :boolean
  end
end
