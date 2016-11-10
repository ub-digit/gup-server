class AddFieldsToTableEndnoteRecords < ActiveRecord::Migration
  def change
    add_column :endnote_records, :title, :text
    add_column :endnote_records, :alt_title, :text
    add_column :endnote_records, :abstract, :text
    add_column :endnote_records, :keywords, :text
    add_column :endnote_records, :pubyear, :integer
    add_column :endnote_records, :language, :text
    add_column :endnote_records, :issn, :text
    add_column :endnote_records, :isbn, :text
    add_column :endnote_records, :sourcetitle, :text
    add_column :endnote_records, :sourcevolume, :text
    add_column :endnote_records, :sourceissue, :text
    add_column :endnote_records, :sourcepages, :text
    add_column :endnote_records, :publisher, :text
    add_column :endnote_records, :place, :text
    add_column :endnote_records, :extent, :text
    add_column :endnote_records, :patent_applicant, :text
    add_column :endnote_records, :patent_date, :text
    add_column :endnote_records, :patent_number, :text
    add_column :endnote_records, :extid, :text
    add_column :endnote_records, :doi_url, :text
    add_column :endnote_records, :xml, :text
  end
end
