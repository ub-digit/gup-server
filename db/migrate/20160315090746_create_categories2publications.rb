class CreateCategories2publications < ActiveRecord::Migration
  def change
    create_table :categories2publications do |t|
    	t.integer :publication_id
    	t.integer :category_id
    	t.timestamps
    end
  end
end
