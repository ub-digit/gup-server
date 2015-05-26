class Publication < ActiveRecord::Base
  default_scope {order('updated_at DESC')}
  
  belongs_to :publication_type
  has_many :people2publications
  nilify_blanks :types => [:text]
  validates_presence_of :pubid
  validate :uniqueness_of_pubid
  validates_inclusion_of :is_draft, in: [true, false]
  validates_inclusion_of :is_deleted, in: [true, false]
  validate :by_publication_type
  
  def self.get_next_pubid
    # PG Specific
    Publication.find_by_sql("SELECT nextval('publications_pubid_seq');").first.nextval.to_i
  end 

  def as_json(options = {})
    super.merge(people2publications: people2publications)
  end


  private
  def uniqueness_of_pubid
    # For a given pubid only one publication should be active
    if is_deleted == false && !Publication.where(pubid: pubid).where(is_deleted: false).empty?
      errors.add(:pubid, 'Pubid should be unique unless publication is deleted')
    end
  end

  def by_publication_type
    if !is_draft
      if publication_type.nil? || publication_type.id == PublicationType.find_by_label("none").id
        errors.add(:publication_type_id, 'Needs a publication type')
      else
        publication_type.validate_publication(self)
      end
    end
  end

  ##### Old code from GUPPI

  def to_people
    return nil unless respond_to?(:people2publications)
    people2publications.map do |p2p| 
      person = ::Person.find(p2p.person_id)
      person.departments = p2p.departments2people2publications

      tmp_arr = []
      p2p.departments2people2publications.each do |d2p2p|
        tmp_arr << {name: d2p2p.name}
      end
      person.departments = tmp_arr
      
      person
    end
  end

  def to_people2publications
    return nil unless respond_to?(:people)
    return nil if people.nil?
    people.map.with_index do |p, i|
      people2publications = {}
      people2publications[:person_id] = p.id  
      people2publications[:position] = i + 1
      people2publications[:departments2people2publications] = p.departments
      people2publications
    end
  end


  def as_json(options = {})
    if @sending
      result = super(except: [:people])
      tmp = to_people2publications
      result["people2publications"] = tmp
    else
      result = super(except: [:people2publications])
      result["people"] = to_people
      result["id"] = result["pubid"]
    end 
    result
  end
  
end
