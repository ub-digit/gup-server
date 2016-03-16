class CreatePublicationFiles < ActiveRecord::Migration
  def change
    create_table :publication_files do |t|
		t.integer :publication_id
		t.text :url
		t.text :mimetype	
		t.text :attrib
		t.text :access_type
		t.text :comments
		t.text :md5sum
		t.datetime :embargo_until, :null => true
		t.text :accept
		t.text :agreement
		t.text :created_by
		t.text :updated_by
		t.timestamps
    end
  end
end




