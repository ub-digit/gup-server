class CreateSeries2publications < ActiveRecord::Migration
  def change
    create_table :series2publications do |t|
    	t.integer :publication_id
    	t.integer :serie_id
    	t.text :serie_part
    	t.integer :serie_listplace
    	t.timestamps
    end
  end
end
