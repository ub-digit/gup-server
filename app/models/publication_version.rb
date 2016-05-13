class PublicationVersion < ActiveRecord::Base
  attr_accessor :new_authors
  belongs_to :publication
  has_many :publication_identifiers, autosave: true
  has_many :people2publications
  has_many :authors, :through => :people2publications, :source => "person"
  has_many :projects2publications
  has_many :projects, :through => :projects2publications
  validate :validate_title
  validate :validate_pubyear
  validate :validate_publication_type

  nilify_blanks :types => [:text]

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
    result["category_objects"] = category_objects.as_json
    result["project_objects"] = project_objects.as_json
    result["series_objects"] = series_objects.as_json

    if self.publication_type.present?
      result["publication_type_label"] = I18n.t('publication_types.'+self.publication_type+'.label')
    end
    if self.content_type.present?
      result["content_type_label"] = I18n.t('content_types.'+self.content_type)
    end
    result["publanguage_label"] = publanguage_label
    result["publication_identifiers"] = publication_identifiers
    
    result
  end
  
  # Returns array with differing attributes used for review
  def review_diff(other)
    diff = {}
    if self.publication_type != other.publication_type
      diff[:publication_type] = {from: I18n.t('publication_types.'+other.publication_type+'.label'), to: I18n.t('publication_types.'+self.publication_type+'.label')}
    end

    unless (self.category_hsv_local & other.category_hsv_local == self.category_hsv_local) && (other.category_hsv_local & self.category_hsv_local == other.category_hsv_local)
      diff[:category_hsv_local] = {from: Category.find_by_ids(other.category_hsv_local), to:  Category.find_by_ids(self.category_hsv_local)}
    end

    if self.content_type != other.content_type
      diff[:content_type] =  {from: I18n.t('content_types.'+other.content_type.to_s), to: I18n.t('content_types.'+self.content_type.to_s)}
    end

    return diff
  end

  private
  def validate_title
    if publication.published_at && title.nil?
      errors.add(:title, :blank)
    end
  end

  def validate_pubyear
    if publication.published_at && pubyear.nil?
      #errors.add(:pubyear, :blank)
    elsif publication.published_at && !is_number?(pubyear)
      errors.add(:pubyear, :no_numerical)
    elsif publication.published_at && pubyear.to_i < 1500
      errors.add(:pubyear, :without_limits)
    end
  end

  # Validate publication type if available
  def validate_publication_type
    if publication.published_at
      if publication_type.nil?
        errors.add(:publication_type, :blank)
      else
        publication_type_object.validate_publication_version(self)
      end
    end
  end

  def publication_type_object
    PublicationType.find_by_code(publication_type)
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

  def is_number? obj
    obj.to_s == obj.to_i.to_s
  end

  # Returns given categories as list of objects
  def category_objects
    Category.find_by_ids(category_hsv_local)
  end

  # Returns given projects as list of objects
  def project_objects
    self.projects
  end

  # returns given series as a list of objects
  def series_objects
    Serie.find_by_ids(self.series)
  end
  
end
