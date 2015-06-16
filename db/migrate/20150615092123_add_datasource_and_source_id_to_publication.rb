class AddDatasourceAndSourceIdToPublication < ActiveRecord::Migration
  def change
    add_column :publications, :datasource, :text
    add_column :publications, :sourceid, :text
  end
end
