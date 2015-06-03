class Identifier < ActiveRecord::Base
  belongs_to :person
  belongs_to :source
  
  validates_presence_of :value

  def as_json()
    {
      id: id,
      source_name: source.name,
      value: value
    }
  end
end
