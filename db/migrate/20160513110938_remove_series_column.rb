class RemoveSeriesColumn < ActiveRecord::Migration
  def change
    remove_column :publication_versions, :series
  end
end
