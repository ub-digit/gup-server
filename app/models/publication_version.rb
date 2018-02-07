class PublicationVersion < ActiveRecord::Base
  attr_accessor :author
  attr_accessor :category_hsv_local
  belongs_to :publication
  belongs_to :publication_type
  has_many :publication_identifiers, autosave: true
  has_many :publication_links
  has_many :people2publications, -> { order(position: :asc) }
  has_many :authors, :through => :people2publications, :source => :person
  has_many :departments, :through => :people2publications
  has_many :projects2publications
  has_many :projects, :through => :projects2publications
  has_many :series2publications
  has_many :series, :through => :series2publications, :source => "serie"
  has_many :categories2publications
  has_many :categories, :through => :categories2publications, :source => "category"

  validates_numericality_of :pubyear, only_integer: true, :if => :is_published?, :allow_blank => true
  validates :pubyear, :numericality => { :greater_than => 1500 }, :if => :is_published?, :allow_blank => true
  validate :validate_publication_type_requirements, :if => :is_published?

  nilify_blanks :types => [:text]

  def ref_value_name
    if self.ref_value.present?
      I18n.t('ref_values.'+self.ref_value)
    end
  end

  def as_json(options = {})
    result = super
    result.delete('id')
    result.delete('created_at')
    result.delete('updated_at')
    result.delete('created_by')
    result.delete('updated_by')
    result.merge!(
      {
        version_id: id,
        version_created_at: created_at,
        version_created_by: created_by,
        version_updated_at: updated_at,
        version_updated_by: updated_by
      })

    if options[:brief]
      result.delete('xml')
      result.delete('datasource')
      result.delete('extid')
    end

    if !options[:brief]
      # Show only HSV_LOCAL_12
      result["category_hsv_local"] = categories.where(category_type: "HSV_LOCAL_12").pluck(:id)
      result["category_objects"] = categories.where(category_type: "HSV_LOCAL_12").as_json(light: true)

      result["project"] = self.projects.pluck(:id)
      result["project_objects"] = projects.as_json
      result["series"] = self.series.pluck(:id)
      result["series_objects"] = series.as_json
      result["publanguage_label"] = publanguage_label
      result["publication_identifiers"] = publication_identifiers
      result["publication_links"] = publication_links
  end

    if options[:include_authors]
      result["authors"] = self.authors.as_json(options)
    end

    if self.publication_type.present?
      result["publication_type_label"] = self.publication_type.name
    end
    if self.ref_value.present?
      result["ref_value_label"] = I18n.t('ref_values.'+self.ref_value)
    end

    result
  end

  # Returns a list of publication identifier values
  def get_identifiers
    identifiers = publication_identifiers.map{|pi| pi.identifier_value}
    identifiers.push(self.isbn) unless !self.isbn
    identifiers.push(self.issn) unless !self.issn
    identifiers.push(self.eissn) unless !self.eissn
    identifiers.push(self.article_number) unless !self.article_number
    return identifiers
  end

  def get_authors_full_name
    authors.map do |a|
      [a.first_name, a.last_name].compact.join(" ")
    end
  end

  def get_authors_identifier(source:)
    authors.map do |a|
      a.get_identifier(source: source)
    end.compact
  end

  def get_no_of_authors
    authors.length
  end

  def is_author?(xaccount:)
    authors.find do |author|
      author.get_identifier(source: "xkonto") == xaccount
    end
  end

  def is_creator?(xaccount:)
    created_by == xaccount
  end

  def is_published?
    publication.is_published?
  end

  def category_svep_ids
    # Only include HSV_LOCAL_12 categories
    categories.where(category_type: "HSV_LOCAL_12").pluck(:svepid)
  end

  # Returns array with differing attributes used for review
  def review_diff(other)
    diff = {}
    if self.publication_type != other.publication_type
      diff[:publication_type] = {from: I18n.t('publication_types.'+other.publication_type.code+'.label'), to: I18n.t('publication_types.'+self.publication_type.code+'.label')}
    end

    unless (self.category_svep_ids & other.category_svep_ids == self.category_svep_ids) && (other.category_svep_ids & self.category_svep_ids == other.category_svep_ids)
      diff[:category_hsv_local] = {from: other.categories, to:  self.categories}
    end

    if self.ref_value != other.ref_value
      diff[:ref_value] =  {from: I18n.t('ref_values.'+other.ref_value.to_s), to: I18n.t('ref_values.'+self.ref_value.to_s)}
    end

    return diff
  end

  private
  # Validate publication type if available
  def validate_publication_type_requirements
    if publication_type.nil?
      errors.add(:publication_type, :blank)
    else
      publication_type.validate_publication_version(self)
    end
  end

  def publanguage_object
    Language.find_by_code(self.publanguage)
  end

  # Returns a locale determined label for chosen language
  def publanguage_label
    if publanguage_object
      return publanguage_object[:label]
    else
      return publanguage
    end
  end

end
