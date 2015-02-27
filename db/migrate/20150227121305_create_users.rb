class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :username
      t.text :first_name
      t.text :last_name
      t.text :role

      t.timestamps null: false
    end
  end
end
