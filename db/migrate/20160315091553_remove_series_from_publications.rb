class RemoveSeriesFromPublications < ActiveRecord::Migration
  def change
	remove_column :publications, :series
  end
end
