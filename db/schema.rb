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

ActiveRecord::Schema.define(version: 20160412141813) do

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

  create_table "alternative_names", force: :cascade do |t|
    t.integer  "person_id"
    t.text     "first_name"
    t.text     "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "alternative_names", ["person_id"], name: "index_alternative_names_on_person_id", using: :btree

  create_table "departments", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "name_sv"
    t.text     "name_en"
    t.integer  "start_year"
    t.integer  "end_year"
    t.integer  "faculty_id"
  end

  create_table "departments2people2publications", force: :cascade do |t|
    t.integer  "people2publication_id"
    t.integer  "department_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "identifiers", force: :cascade do |t|
    t.integer  "person_id"
    t.integer  "source_id"
    t.text     "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "identifiers", ["person_id"], name: "index_identifiers_on_person_id", using: :btree
  add_index "identifiers", ["source_id"], name: "index_identifiers_on_source_id", using: :btree

  create_table "people", force: :cascade do |t|
    t.integer  "year_of_birth"
    t.text     "first_name"
    t.text     "last_name"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "affiliated",    default: false
    t.datetime "deleted_at"
  end

  create_table "people2publications", force: :cascade do |t|
    t.integer  "publication_version_id"
    t.integer  "person_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "reviewed_at"
    t.integer  "reviewed_publication_version_id"
  end

  create_table "publication_identifiers", force: :cascade do |t|
    t.integer  "publication_version_id"
    t.text     "identifier_code"
    t.text     "identifier_value"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "publication_versions", force: :cascade do |t|
    t.integer  "publication_id"
    t.text     "publication_type"
    t.text     "content_type"
    t.text     "title"
    t.text     "alt_title"
    t.text     "abstract"
    t.integer  "pubyear"
    t.text     "publanguage"
    t.integer  "category_hsv_local",        default: [], array: true
    t.text     "url"
    t.text     "keywords"
    t.integer  "project",                   default: [], array: true
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
    t.integer  "series",                    default: [], array: true
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

  create_table "publications", force: :cascade do |t|
    t.datetime "published_at"
    t.datetime "deleted_at"
    t.integer  "current_version_id"
    t.datetime "biblreview_postponed_until"
    t.text     "biblreview_postpone_comment"
    t.datetime "epub_ahead_of_print"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

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

end
