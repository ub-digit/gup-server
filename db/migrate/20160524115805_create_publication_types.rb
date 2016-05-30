class CreatePublicationTypes < ActiveRecord::Migration
  def change
    create_table :publication_types do |t|

      t.string :code, null: false
      t.string :ref_options, null: false
      t.timestamps null: false
    end
  end
end
