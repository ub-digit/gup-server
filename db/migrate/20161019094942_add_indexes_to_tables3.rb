class AddIndexesToTables3 < ActiveRecord::Migration
  def change
    add_index :categories, :parent_id
    add_index :categories2publications, :category_id
    add_index :departments, :start_year
    add_index :departments, :end_year
    add_index :departments, :parentid
    add_index :departments, :grandparentid
    add_index :departments, :faculty_id
    add_index :fields2publication_types, :field_id
    add_index :fields2publication_types, :publication_type_id
    add_index :journal_identifiers, :journal_id
    add_index :journals, :start_year
    add_index :journals, :end_year
    add_index :messages, :deleted_at
    add_index :people, :deleted_at
    add_index :people2publications, :reviewed_publication_version_id
    add_index :postpone_dates, :publication_id
    add_index :postpone_dates, :deleted_at
    add_index :projects, :start_year
    add_index :projects, :end_year
    add_index :projects2publications, :publication_version_id
    add_index :projects2publications, :project_id
    add_index :publication_files, :publication_id
    add_index :publication_links, :publication_id
    add_index :publication_versions, :journal_id
    add_index :publication_versions, :publication_type_id
    add_index :publications, :current_version_id
    add_index :publications, :deleted_at
    add_index :series, :start_year
    add_index :series, :end_year
    add_index :series2publications, :publication_version_id
    add_index :series2publications, :serie_id
    add_index :users, :username
  end
end
