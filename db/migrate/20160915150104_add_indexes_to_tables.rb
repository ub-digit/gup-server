class AddIndexesToTables < ActiveRecord::Migration
  def change
    add_index :publication_versions, :publication_id
    add_index :people2publications, :publication_version_id
    add_index :people2publications, :person_id
    add_index :departments2people2publications, :department_id
    add_index :departments2people2publications, :people2publication_id
    add_index :categories2publications, :publication_version_id
    add_index :publication_identifiers, :publication_version_id          	
  end
end
