class PublicationLink < ActiveRecord::Base
  validates :publication_version_id, :presence => true
  validates :url, :presence => true #TODO: Stricter validation?
  belongs_to :publication_version
end
