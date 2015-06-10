class AddColumnXmlToPublications < ActiveRecord::Migration
  def change
  	add_column :publications, :xml, :text
  end
end
