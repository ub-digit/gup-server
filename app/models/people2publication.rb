class People2publication  < ActiveRecord::Base
  belongs_to :publication
  belongs_to :reviewed_publication, class_name: "Publication", foreign_key: "reviewed_publication_id"
  belongs_to :person
  has_many :departments2people2publications
  
  validates :publication, presence: true
  validates :person, presence: true
  validates :position, presence: true, uniqueness: { scope: :publication_id}

  def as_json(options = {})
    super.merge(departments2people2publications: departments2people2publications)
  end

end


