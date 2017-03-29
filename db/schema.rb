# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170324074749) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "token"
    t.datetime "token_expire"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.text     "username"
  end

  add_index "access_tokens", ["token"], name: "index_access_tokens_on_token", using: :btree
  add_index "access_tokens", ["token_expire"], name: "index_access_tokens_on_token_expire", using: :btree

  create_table "alternative_names", force: :cascade do |t|
    t.integer  "person_id"
    t.text     "first_name"
    t.text     "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "alternative_names", ["person_id"], name: "index_alternative_names_on_person_id", using: :btree

  create_table "asset_data", force: :cascade do |t|
    t.integer  "publication_id"
    t.text     "name"
    t.text     "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.text     "accepted"
    t.text     "created_by"
    t.text     "deleted_by"
    t.text     "checksum"
    t.date     "visible_after"
    t.text     "tmp_token"
  end

  add_index "asset_data", ["deleted_at"], name: "index_asset_data_on_deleted_at", using: :btree
  add_index "asset_data", ["publication_id"], name: "index_asset_data_on_publication_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.text     "name_sv"
    t.text     "name_en"
    t.integer  "svepid"
    t.integer  "parent_id"
    t.text     "category_type"
    t.text     "node_type"
    t.integer  "node_level"
    t.text     "en_name_path"
    t.text     "sv_name_path"
    t.integer  "mapping_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree

  create_table "categories2publications", force: :cascade do |t|
    t.integer  "publication_version_id"
    t.integer  "category_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "categories2publications", ["category_id"], name: "index_categories2publications_on_category_id", using: :btree
  add_index "categories2publications", ["publication_version_id"], name: "index_categories2publications_on_publication_version_id", using: :btree

  create_table "departments", force: :cascade do |t|
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "name_sv"
    t.text     "name_en"
    t.integer  "start_year"
    t.integer  "end_year"
    t.integer  "faculty_id"
    t.integer  "parentid"
    t.integer  "grandparentid"
    t.text     "created_by"
    t.text     "updated_by"
    t.text     "staffnotes"
    t.text     "palassoid"
    t.text     "kataguid"
    t.boolean  "is_internal",   default: true
  end

  add_index "departments", ["end_year"], name: "index_departments_on_end_year", using: :btree
  add_index "departments", ["faculty_id"], name: "index_departments_on_faculty_id", using: :btree
  add_index "departments", ["grandparentid"], name: "index_departments_on_grandparentid", using: :btree
  add_index "departments", ["parentid"], name: "index_departments_on_parentid", using: :btree
  add_index "departments", ["start_year"], name: "index_departments_on_start_year", using: :btree

  create_table "departments2people2publications", force: :cascade do |t|
    t.integer  "people2publication_id"
    t.integer  "department_id"
    t.integer  "position"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "departments2people2publications", ["department_id"], name: "index_departments2people2publications_on_department_id", using: :btree
  add_index "departments2people2publications", ["people2publication_id"], name: "index_departments2people2publications_on_people2publication_id", using: :btree
  add_index "departments2people2publications", ["people2publication_id"], name: "ix_d2p2p", using: :btree

  create_table "endnote_file_records", force: :cascade do |t|
    t.integer  "endnote_file_id"
    t.integer  "endnote_record_id"
    t.integer  "position"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "endnote_file_records", ["endnote_file_id"], name: "index_endnote_file_records_on_endnote_file_id", using: :btree
  add_index "endnote_file_records", ["endnote_record_id"], name: "index_endnote_file_records_on_endnote_record_id", using: :btree

  create_table "endnote_files", force: :cascade do |t|
    t.text     "name"
    t.text     "username"
    t.text     "xml"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "endnote_files", ["username"], name: "index_endnote_files_on_username", using: :btree

  create_table "endnote_records", force: :cascade do |t|
    t.integer  "publication_id"
    t.text     "checksum"
    t.text     "username"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.text     "title"
    t.text     "alt_title"
    t.text     "abstract"
    t.text     "keywords"
    t.integer  "pubyear"
    t.text     "language"
    t.text     "issn"
    t.text     "isbn"
    t.text     "sourcetitle"
    t.text     "sourcevolume"
    t.text     "sourceissue"
    t.text     "sourcepages"
    t.text     "publisher"
    t.text     "place"
    t.text     "extent"
    t.text     "patent_applicant"
    t.text     "patent_date"
    t.text     "patent_number"
    t.text     "extid"
    t.text     "doi_url"
    t.text     "xml"
    t.text     "doi"
    t.integer  "rec_number"
    t.text     "db_id"
  end

  add_index "endnote_records", ["checksum"], name: "index_endnote_records_on_checksum", using: :btree
  add_index "endnote_records", ["publication_id"], name: "index_endnote_records_on_publication_id", using: :btree

  create_table "faculties", force: :cascade do |t|
    t.text     "name_sv"
    t.text     "name_en"
    t.text     "created_by"
    t.text     "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fields", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fields2publication_types", force: :cascade do |t|
    t.integer  "field_id",            null: false
    t.integer  "publication_type_id", null: false
    t.string   "rule",                null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "fields2publication_types", ["field_id"], name: "index_fields2publication_types_on_field_id", using: :btree
  add_index "fields2publication_types", ["publication_type_id"], name: "index_fields2publication_types_on_publication_type_id", using: :btree

  create_table "identifiers", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "source_id"
    t.text     "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "identifiers", ["person_id"], name: "index_identifiers_on_person_id", using: :btree
  add_index "identifiers", ["source_id"], name: "index_identifiers_on_source_id", using: :btree

  create_table "journal_identifiers", force: :cascade do |t|
    t.integer  "journal_id"
    t.text     "identifier_type"
    t.text     "value"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "journal_identifiers", ["journal_id"], name: "index_journal_identifiers_on_journal_id", using: :btree

  create_table "journals", force: :cascade do |t|
    t.text     "title"
    t.text     "publisher"
    t.text     "place"
    t.integer  "start_year"
    t.integer  "end_year"
    t.text     "source"
    t.text     "created_by"
    t.text     "updated_by"
    t.text     "abbreviation"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "journals", ["end_year"], name: "index_journals_on_end_year", using: :btree
  add_index "journals", ["start_year"], name: "index_journals_on_start_year", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "message_type"
    t.string   "message"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "deleted_at"
    t.string   "deleted_by"
    t.string   "created_by"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "messages", ["deleted_at"], name: "index_messages_on_deleted_at", using: :btree

  create_table "people", force: :cascade do |t|
    t.integer  "year_of_birth"
    t.text     "first_name"
    t.text     "last_name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.text     "created_by"
    t.text     "updated_by"
    t.text     "staffnotes"
    t.datetime "deleted_at"
  end

  add_index "people", ["deleted_at"], name: "index_people_on_deleted_at", using: :btree

  create_table "people2publications", force: :cascade do |t|
    t.integer  "publication_version_id"
    t.integer  "person_id"
    t.integer  "position"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.datetime "reviewed_at"
    t.integer  "reviewed_publication_version_id"
  end

  add_index "people2publications", ["person_id"], name: "index_people2publications_on_person_id", using: :btree
  add_index "people2publications", ["publication_version_id"], name: "index_people2publications_on_publication_version_id", using: :btree
  add_index "people2publications", ["publication_version_id"], name: "ix_people2publications2", using: :btree
  add_index "people2publications", ["reviewed_publication_version_id"], name: "index_people2publications_on_reviewed_publication_version_id", using: :btree

  create_table "postpone_dates", force: :cascade do |t|
    t.integer  "publication_id"
    t.datetime "postponed_until"
    t.datetime "deleted_at"
    t.text     "deleted_by"
    t.text     "created_by"
    t.text     "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment"
  end

  add_index "postpone_dates", ["deleted_at"], name: "index_postpone_dates_on_deleted_at", using: :btree
  add_index "postpone_dates", ["publication_id"], name: "index_postpone_dates_on_publication_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.text     "title"
    t.text     "abbrev"
    t.text     "project_number"
    t.text     "description"
    t.text     "keywords"
    t.text     "url"
    t.integer  "start_year"
    t.integer  "end_year"
    t.text     "created_by"
    t.text     "updated_by"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "projects", ["end_year"], name: "index_projects_on_end_year", using: :btree
  add_index "projects", ["start_year"], name: "index_projects_on_start_year", using: :btree

  create_table "projects2publications", force: :cascade do |t|
    t.integer  "publication_version_id"
    t.integer  "project_id"
    t.integer  "project_listplace"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "projects2publications", ["project_id"], name: "index_projects2publications_on_project_id", using: :btree
  add_index "projects2publications", ["publication_version_id"], name: "index_projects2publications_on_publication_version_id", using: :btree

  create_table "publication_files", force: :cascade do |t|
    t.integer  "publication_id"
    t.text     "url"
    t.text     "mimetype"
    t.text     "attrib"
    t.text     "access_type"
    t.text     "comments"
    t.text     "md5sum"
    t.datetime "embargo_until"
    t.text     "accept"
    t.text     "agreement"
    t.text     "created_by"
    t.text     "updated_by"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "publication_files", ["publication_id"], name: "index_publication_files_on_publication_id", using: :btree

  create_table "publication_identifiers", force: :cascade do |t|
    t.integer  "publication_version_id"
    t.text     "identifier_code"
    t.text     "identifier_value"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "publication_identifiers", ["identifier_code"], name: "index_publication_identifiers_on_identifier_code", using: :btree
  add_index "publication_identifiers", ["identifier_value"], name: "index_publication_identifiers_on_identifier_value", using: :btree
  add_index "publication_identifiers", ["publication_version_id"], name: "index_publication_identifiers_on_publication_version_id", using: :btree

  create_table "publication_links", force: :cascade do |t|
    t.text     "url"
    t.integer  "publication_version_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "position"
  end

  add_index "publication_links", ["publication_version_id"], name: "index_publication_links_on_publication_version_id", using: :btree

  create_table "publication_types", force: :cascade do |t|
    t.string   "code",           null: false
    t.string   "ref_options",    null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.text     "label_sv"
    t.text     "label_en"
    t.text     "description_sv"
    t.text     "description_en"
  end

  create_table "publication_versions", force: :cascade do |t|
    t.integer  "publication_id"
    t.text     "content_type"
    t.text     "title"
    t.text     "alt_title"
    t.text     "abstract"
    t.integer  "pubyear"
    t.text     "publanguage"
    t.text     "url"
    t.text     "keywords"
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
    t.text     "created_by"
    t.text     "updated_by"
    t.text     "xml"
    t.text     "datasource"
    t.text     "extid"
    t.text     "sourceid"
    t.datetime "biblreviewed_at"
    t.text     "biblreviewed_by"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "publication_type_id"
    t.string   "ref_value"
  end

  add_index "publication_versions", ["created_by"], name: "index_publication_versions_on_created_by", using: :btree
  add_index "publication_versions", ["journal_id"], name: "index_publication_versions_on_journal_id", using: :btree
  add_index "publication_versions", ["publication_id"], name: "index_publication_versions_on_publication_id", using: :btree
  add_index "publication_versions", ["publication_type_id"], name: "index_publication_versions_on_publication_type_id", using: :btree
  add_index "publication_versions", ["updated_by"], name: "index_publication_versions_on_updated_by", using: :btree

  create_table "publications", force: :cascade do |t|
    t.datetime "published_at"
    t.datetime "deleted_at"
    t.integer  "current_version_id"
    t.datetime "epub_ahead_of_print"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.text     "process_state"
  end

  add_index "publications", ["current_version_id"], name: "index_publications_on_current_version_id", using: :btree
  add_index "publications", ["current_version_id"], name: "ix_current_version_id", using: :btree
  add_index "publications", ["deleted_at"], name: "index_publications_on_deleted_at", using: :btree

  create_table "series", force: :cascade do |t|
    t.text     "title"
    t.text     "issn"
    t.integer  "start_year"
    t.integer  "end_year"
    t.text     "created_by"
    t.text     "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "series", ["end_year"], name: "index_series_on_end_year", using: :btree
  add_index "series", ["start_year"], name: "index_series_on_start_year", using: :btree

  create_table "series2publications", force: :cascade do |t|
    t.integer  "publication_version_id"
    t.integer  "serie_id"
    t.text     "serie_part"
    t.integer  "serie_listplace"
    t.text     "created_by"
    t.text     "updated_by"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "series2publications", ["publication_version_id"], name: "index_series2publications_on_publication_version_id", using: :btree
  add_index "series2publications", ["serie_id"], name: "index_series2publications_on_serie_id", using: :btree

  create_table "sources", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.text     "username"
    t.text     "first_name"
    t.text     "last_name"
    t.text     "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  add_foreign_key "publication_links", "publication_versions"
end
