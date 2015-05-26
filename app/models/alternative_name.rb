class AlternativeName < ActiveRecord::Base
  belongs_to :person

  validates :person, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true

  def as_json()
    {
      id: id,
      first_name: first_name,
      last_name: last_name
    }
  end
end
