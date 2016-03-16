class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
    	t.text :title
		t.text :abbrev
		t.text :project_number
		t.text :description
		t.text :keywords
		t.text :url
		t.integer :start_year
		t.integer :end_year
		t.text :created_by
		t.text :updated_by
		t.timestamps
    end
  end
end
