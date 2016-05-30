class CreatePublicationTypes < ActiveRecord::Migration
  def change
  	create_table "publication_types", force: :cascade do |t|
	    t.string   "code",        null: false
	    t.string   "ref_options", null: false
	    t.datetime "created_at",  null: false
	    t.datetime "updated_at",  null: false
 	end
  end
end
