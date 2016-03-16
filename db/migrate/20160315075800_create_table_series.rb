class CreateTableSeries < ActiveRecord::Migration
  def change
    create_table :series do |t|
    	t.text :title
    	t.text :issn
    	t.integer :start_year
    	t.integer :end_year
    	t.text :created_by
    	t.text :updated_by
    	t.timestamps
    end
  end
end
