class People2publication  < ActiveRecord::Base
  belongs_to :publication_version
  belongs_to :reviewed_publication_version, class_name: "PublicationVersion", foreign_key: "reviewed_publication_version_id"
  belongs_to :person
  has_many :departments2people2publications
  
  validates :publication_version, presence: true
  validates :person, presence: true
  validates :position, presence: true, uniqueness: { scope: :publication_version_id}

  def as_json(options = {})
    super.merge(departments2people2publications: departments2people2publications)
  end

end


