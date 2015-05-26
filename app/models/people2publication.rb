class People2publication  < ActiveRecord::Base
  belongs_to :publication
  has_many :departments2people2publications
  
  validates :publication_id, presence: true
  validates :person_id, presence: true
  validates :position, presence: true, uniqueness: { scope: :publication_id}

  def as_json(options = {})
    super.merge(departments2people2publications: departments2people2publications)
  end

end


