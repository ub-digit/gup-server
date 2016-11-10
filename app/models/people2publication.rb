class People2publication  < ActiveRecord::Base
  belongs_to :publication_version
  # Perhaps some explanation needed for this one:
  belongs_to :current_publication, class_name: "Publication", foreign_key: "publication_version_id", primary_key: "current_version_id"

  belongs_to :reviewed_publication_version, class_name: "PublicationVersion", foreign_key: "reviewed_publication_version_id"
  belongs_to :person
  has_many :departments2people2publications
  has_many :departments, :source => :department, :through => :departments2people2publications

  validates :publication_version, presence: true
  validates :person, presence: true
  validates :position, presence: true, uniqueness: { scope: :publication_version_id }
  validates :person_id,
    uniqueness: {
      scope: [:publication_version_id],
      message: ->(object, data) do
        #TODO: Is there a more proper way?
        person = Person.find_by_id(data[:value])
        if person.present?
          # #{People2publication.i18n_scope}.errors.messages ?
          I18n.t(:"publications.errors.nonunique_author", :author_presentation => person.presentation_string)
        else
          #TODO: this should never happen, handle differently? Log? Crash harder?
          I18n.t(:"publications.errors.nonunique_nonexistent_author")
        end
      end
    }

  def as_json(options = {})
    super.merge(departments2people2publications: departments2people2publications)
  end

end
