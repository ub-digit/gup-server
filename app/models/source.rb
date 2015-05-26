class Source < ActiveRecord::Base
  has_many :identifiers
  has_many :people, :through => :identifiers

  validates :name, presence: true, allow_blank: false
  validates_uniqueness_of :name, case_sensitive: false

  def as_json()
    {
      id: id,
      name: name,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
