class PostponeDates < ActiveRecord::Migration
  def change
    create_table :postpone_dates do |t|
    	t.integer :publication_id
    	t.datetime :postponed_until
    	t.datetime :deleted_at
    	t.text :deleted_by
    	t.text :created_by
    	t.text :updated_by
    	t.timestamps
    end
  end
end
