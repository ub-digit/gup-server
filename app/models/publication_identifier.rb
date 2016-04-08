class PublicationIdentifier < ActiveRecord::Base
  belongs_to :publication_version
  validates :publication_version_id, :identifier_code, :identifier_value, :presence => true
  validates :identifier_code, :inclusion => {in: APP_CONFIG['publication_identifier_codes'].map{|x| x['code']}}

  def get_label
    APP_CONFIG['publication_identifier_codes'].select{|x| x["code"] == self.identifier_code}.first["label"]
  rescue
    "MISSING: #{self.identifier_code}"
  end

  def as_json(opts={})
    super().merge(
      {
        identifier_label: get_label
      }
    )
  end
end
