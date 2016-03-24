class Publication < ActiveRecord::Base
  attr_accessor :new_authors
  has_many :people2publications
  has_many :authors, :through => :people2publications, :source => "person"
  has_many :publication_identifiers, autosave: true
  has_many :categories2publications
  has_many :categories, :through => :categories2publications
  #has_many :series2publications
  #has_many :series, :through => :series2publications, :source => "series"
  has_many :projects2publications
  has_many :projects, :through => :projects2publications
  default_scope {order('updated_at DESC')}

  nilify_blanks :types => [:text]
  validates_presence_of :pubid
  validate :uniqueness_of_pubid
  validates_inclusion_of :is_deleted, in: [true, false]
  validate :validate_title
  validate :validate_pubyear
  validate :validate_publication_type
  
  def self.get_next_pubid
    # PG Specific
    Publication.find_by_sql("SELECT nextval('publications_pubid_seq');").first.nextval.to_i
  end 

  def as_json(options = {})
    result = super
    result["db_id"] = result["id"]
    result["id"] = result["pubid"]
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

  # Used for cloning an existing post
  def attributes_indifferent
    ActiveSupport::HashWithIndifferentAccess.new(self.attributes)
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

  def series
    []
  end


  private
  def uniqueness_of_pubid
    # For a given pubid only one publication should be active
    if is_deleted == false && !Publication.where.not(id: id).where(pubid: pubid).where(is_deleted: false).empty?
      errors.add(:pubid, :unique_unless_deleted)
    end
  end

  def validate_title
    if published_at && title.nil?
      errors.add(:title, :blank)
    end
  end

  def validate_pubyear
    if published_at && pubyear.nil?
      #errors.add(:pubyear, :blank)
    elsif published_at && !is_number?(pubyear)
      errors.add(:pubyear, :no_numerical)
    elsif published_at && pubyear.to_i < 1500
      errors.add(:pubyear, :without_limits)
    end
  end

  # Validate publication type if available
  def validate_publication_type
    if published_at
      if publication_type.nil?
        errors.add(:publication_type, :blank)
      else
        publication_type_object.validate_publication(self)
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
    categories
#    Category.find_by_ids(category_hsv_local)
  end

  # Returns given projects as list of objects
  def project_objects
    projects
#    Project.find_by_ids(self.project)
  end

  # returns given series as a list of objects
  def series_objects
    []
    #series
#    Serie.find_by_ids(self.series)
  end
  
end
