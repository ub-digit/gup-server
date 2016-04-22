class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|

      t.string :message_type
      t.string :message
      t.date :start_date
      t.date :end_date
      t.datetime :deleted_at
      t.string :deleted_by
      t.string :created_by
      t.timestamps null: false
    end
  end
end
