class ChangeFieldMappingTable < ActiveRecord::Migration
  def change
    rename_table :fields2_publication_types, :fields2publication_types
  end
end
