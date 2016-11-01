class EndNoteFile < ActiveRecord::Base
  has_many :end_note_items
  has_many :publications, :through => :end_note_items

  validates :id, :uniqueness => true
  validates :username, :presence => true
  validates :xml, :presence => true

  # def as_json()
  #   {
  #     id: id,
  #     username: username,
  #     xml: xml
  #   }
  # end
end
