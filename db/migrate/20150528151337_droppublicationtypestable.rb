class Droppublicationtypestable < ActiveRecord::Migration
  def change
    drop_table :publication_types
  end
end
