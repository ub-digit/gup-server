class Publication < ActiveRecord::Base
  has_many :publication_versions
  belongs_to :current_version, class_name: "PublicationVersion", foreign_key: "current_version_id"
  default_scope {order('updated_at DESC')}

  nilify_blanks :types => [:text]

  def as_json(options = {})
    result = super
    if(options[:version])
      result.merge!(options[:version].as_json)
    else
      result.merge!(current_version.as_json)
    end
    result[:versions] = publication_versions.order(:id).reverse_order.map do |v| 
      {
        id: v.id,

        # This is VERY VERY VERY much a temporary solution
        # because the old code did not set a new created_at
        # when creating a new version. The created_at that
        # is set now is in general the same as updated_at
        # but does not have to be true in all cases
        created_at: v.updated_at,

        created_by: v.created_by,
        updated_at: v.updated_at,
        updated_by: v.updated_by
      }
    end
    result
  end

  # Used for cloning an existing post
  def attributes_indifferent
    ActiveSupport::HashWithIndifferentAccess.new(self.as_json)
  end

  # Split and build new publication and its first version
  def self.build_new(params)
    publication = Publication.new
    publication.current_version = publication.build_version(params)
    publication
  end

  # Save new publication and its first version
  def save_new
    Publication.transaction do
      if(save)
        if(!save_version(version: current_version))
          raise ActiveRecord::Rollback
        end
      end
    end
    return true
  end
  
  # Build new publication version
  def build_version(params)
    publication_versions.build(params)
  end

  # Save publication version and set as current version
  def save_version(version:)
    version.created_at = Time.now
    if version.save
      set_current_version(version_id: version.id)
      return true
    else
      version.errors.messages.each do |key, value|
        errors.add(key, value)
      end
      return false
    end
  end

  def set_current_version(version_id:)
    update_attribute(:current_version_id, version_id)
  end

end
