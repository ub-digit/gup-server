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

ActiveRecord::Schema.define(version: 20150615092123) do

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
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
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
  end

  create_table "people2publications", force: :cascade do |t|
    t.integer  "publication_id"
    t.integer  "person_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "reviewed_at"
    t.integer  "reviewed_publication_id"
  end

  create_table "publications", force: :cascade do |t|
    t.text     "title"
    t.integer  "pubyear"
    t.text     "abstract"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "issn"
    t.text     "isbn"
    t.text     "alt_title"
    t.text     "publanguage"
    t.text     "extid"
    t.text     "links"
    t.text     "url"
    t.text     "keywords"
    t.text     "pub_notes"
    t.text     "sourcetitle"
    t.text     "sourcevolume"
    t.text     "sourceissue"
    t.text     "sourcepages"
    t.text     "project"
    t.text     "eissn"
    t.text     "extent"
    t.text     "publisher"
    t.text     "place"
    t.text     "series"
    t.text     "artwork_type"
    t.text     "dissdate"
    t.text     "disstime"
    t.text     "disslocation"
    t.text     "dissopponent"
    t.text     "patent_applicant"
    t.text     "patent_application_number"
    t.text     "patent_application_date"
    t.text     "patent_number"
    t.text     "patent_date"
    t.text     "article_number"
    t.boolean  "is_saved"
    t.integer  "pubid",                     limit: 8
    t.boolean  "is_deleted"
    t.text     "created_by"
    t.text     "updated_by"
    t.text     "publication_type"
    t.text     "content_type"
    t.integer  "category_hsv_local",                  default: [], array: true
    t.datetime "published_at"
    t.text     "xml"
    t.text     "datasource"
    t.text     "sourceid"
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
