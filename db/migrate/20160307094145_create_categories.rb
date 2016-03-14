class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
    	t.text :name_sv
    	t.text :name_en
    	t.integer :svepid
    	t.integer :parent_id
    	t.text :category_type
    	t.text :node_type
    	t.integer :node_level
    	t.text :en_name_path
    	t.text :sv_name_path
    	t.integer :mapping_id
    	t.timestamps
    end
  end
end
