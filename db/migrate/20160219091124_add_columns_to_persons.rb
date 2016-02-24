class AddColumnsToPersons < ActiveRecord::Migration
  def change
    add_column :people, :created_by, :text
    add_column :people, :updated_by, :text
    add_column :people, :staffnotes, :text
  end
end
