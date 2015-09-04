class PublicationIdentifier < ActiveRecord::Base
  belongs_to :publication
  validates :publication_id, :identifier_code, :identifier_value, :presence => true
  validates :identifier_code, :inclusion => {in: APP_CONFIG['publication_identifier_codes'].map{|x| x['code']}}
end
