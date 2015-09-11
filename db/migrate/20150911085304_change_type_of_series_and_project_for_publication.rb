class ChangeTypeOfSeriesAndProjectForPublication < ActiveRecord::Migration
  def change
    remove_column :publications, :series
    add_column :publications, :series, :integer, array: true, default: []
    remove_column :publications, :project
    add_column :publications, :project, :integer, array: true, default: []
  end
end
