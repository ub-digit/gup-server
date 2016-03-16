class CreateSeries2publications < ActiveRecord::Migration
  def change
    create_table :series2publications do |t|
    	t.integer :publication_id
    	t.integer :series_id
    	t.text :series_part
    	t.integer :series_listplace
    	t.timestamps
    end
  end
end
