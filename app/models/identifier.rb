class Identifier < ActiveRecord::Base
  belongs_to :person
  belongs_to :source
  validates :value, :presence => true

  def as_json()
    {
      id: id,
      source_name: source.name,
      value: value
    }
  end
end
