class CreateProjects2publications < ActiveRecord::Migration
  def change
    create_table :projects2publications do |t|
		t.integer :publication_id
		t.integer :project_id
		t.integer :project_listplace
		t.timestamps
    end
  end
end
