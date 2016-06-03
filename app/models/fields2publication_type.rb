class Fields2publicationType < ActiveRecord::Base
  belongs_to :field
  belongs_to :publication_type

  validates_presence_of :field
  validates_presence_of :publication_type
  validates_presence_of :rule
  validates_inclusion_of :rule, in: ['R', 'O']

  def as_json options={}
    super.merge({
      label: field.label(publication_type: publication_type.code),
      name: field.name
    })
  end
end
