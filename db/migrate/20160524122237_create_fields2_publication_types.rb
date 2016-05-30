class CreateFields2PublicationTypes < ActiveRecord::Migration
  def change
    create_table :fields2_publication_types do |t|

      t.integer :field_id, null: false
      t.integer :publication_type_id, null: false
      t.string :rule, null: false
      t.timestamps null: false
    end
  end
end
