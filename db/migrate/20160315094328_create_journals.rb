class CreateJournals < ActiveRecord::Migration
  def change
    create_table :journals do |t|
		t.text :title
		t.text :publisher
		t.text :place
		t.integer :start_year
		t.integer :end_year
		t.text :source
		t.text :created_by
		t.text :updated_by
		t.text :abbreviation
		t.timestamps
    end
  end
end
