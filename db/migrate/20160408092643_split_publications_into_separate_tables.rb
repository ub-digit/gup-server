class SplitPublicationsIntoSeparateTables < ActiveRecord::Migration
  def change
    Departments2people2publication.delete_all
    People2publication.delete_all
    PublicationIdentifier.delete_all
    drop_table :publications
    
    create_table :publications do |t| 
      t.datetime :published_at
      t.datetime :deleted_at
      t.integer :current_version_id
      t.datetime :biblreview_postponed_until
      t.text :biblreview_postpone_comment
      t.datetime :epub_ahead_of_print
      t.timestamps null: false
    end
    
    create_table :publication_versions do |t| 
      t.integer :publication_id
      t.text     "publication_type"
      t.text     "content_type"

      t.text     "title"
      t.text     "alt_title"
      t.text     "abstract"
      t.integer  "pubyear"
      t.text     "publanguage"
      t.integer  "category_hsv_local",                  default: [], array: true
      t.text     "url"
      t.text     "keywords"
      t.integer  "project",                             default: [], array: true
      t.text     "pub_notes"

      t.integer  "journal_id"
      t.text     "sourcetitle"
      t.text     "sourcevolume"
      t.text     "sourceissue"
      t.text     "sourcepages"
      t.text     "issn"
      t.text     "eissn"
      t.text     "article_number"
      t.text     "extent"
      t.text     "publisher"
      t.text     "place"
      t.integer  "series",                              default: [], array: true

      t.text     "isbn"
      t.text     "artwork_type"
      t.text     "dissdate"
      t.text     "dissopponent"

      t.text     "patent_applicant"
      t.text     "patent_application_number"
      t.text     "patent_application_date"
      t.text     "patent_number"
      t.text     "patent_date"

      t.boolean  "is_saved"

      t.text     "datasource"
      t.text     "extid"
      t.text     "sourceid"
      t.text     "links"
      t.text     "xml"

      t.datetime "biblreviewed_at"
      t.text     "biblreviewed_by"
      t.datetime "created_at"
      t.text     "created_by"
      t.datetime "updated_at"
      t.text     "updated_by"
    end

    rename_column :people2publications, :publication_id, :publication_version_id
    rename_column :people2publications, :reviewed_publication_id, :reviewed_publication_version_id
    rename_column :publication_identifiers, :publication_id, :publication_version_id
  end
end
