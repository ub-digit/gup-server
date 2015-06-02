class Publication < ActiveRecord::Base
  has_many :people2publications

  default_scope {order('updated_at DESC')}

  nilify_blanks :types => [:text]
  validates_presence_of :pubid
  validate :uniqueness_of_pubid
  validates_inclusion_of :is_draft, in: [true, false]
  validates_inclusion_of :is_deleted, in: [true, false]
  validate :validate_title
  validate :validate_pubyear
  validate :validate_publication_type
  
  def self.get_next_pubid
    # PG Specific
    Publication.find_by_sql("SELECT nextval('publications_pubid_seq');").first.nextval.to_i
  end 

  def as_json(options = {})
    super.merge(people2publications: people2publications)
  end

  def as_json(options = {})
    result = super(except: [:people2publications])
    result["id"] = result["pubid"]
    result
  end

  # Used for cloning an existing post
  def attributes_indifferent
    ActiveSupport::HashWithIndifferentAccess.new(self.attributes)
  end

  private
  def uniqueness_of_pubid
    # For a given pubid only one publication should be active
    if is_deleted == false && !Publication.where(pubid: pubid).where(is_deleted: false).empty?
      errors.add(:pubid, 'Pubid should be unique unless publication is deleted')
    end
  end

  def validate_title
    if !is_draft && title.nil?
      errors.add(:title, 'Needs a title')
    end
  end

  def validate_pubyear
    if !is_draft && pubyear.nil?
      errors.add(:pubyear, 'Needs a pubyear')
    end
    if !is_draft && !is_number?(pubyear)
      errors.add(:pubyear, 'Publication year must be numerical')
    end
    if !is_draft && pubyear.to_i < 1500
      errors.add(:pubyear, 'Publication year must be within reasonable limits')
    end
  end

  # Validate publication type if available
  def validate_publication_type
    if !is_draft
      if publication_type.nil?
        errors.add(:publication_type, 'Needs a publication type')
      else
        publication_type_object.validate_publication(self)
      end
    end
  end

  def publication_type_object
    PublicationType.find_by_code(publication_type)
  end

  def is_number? obj
    obj.to_s == obj.to_i.to_s
  end

  
end
