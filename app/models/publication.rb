class Publication < ActiveRecord::Base
  has_many :publication_versions
  has_many :postpone_dates
  belongs_to :current_version, class_name: "PublicationVersion", foreign_key: "current_version_id"
  default_scope {order('updated_at DESC')}

  nilify_blanks :types => [:text]

  def is_draft?
    published_at.nil?
  end

  def is_published?
    published_at.present?
  end

  def as_json(options = {})
    result = super
    selected_version = options[:version]
    if(selected_version)
      result.merge!(options[:version].as_json)
    else
      result.merge!(current_version.as_json)
    end
    result[:versions] = publication_versions.order(:id).reverse_order.map do |v| 
      {
        id: v.id,
        created_at: v.created_at,
        created_by: v.created_by,
        updated_at: v.updated_at,
        updated_by: v.updated_by
      }
    end
    result[:biblreview_postponed_until] = biblreview_postponed_until
    result
  end

  # Used for cloning an existing post
  def attributes_indifferent
    ActiveSupport::HashWithIndifferentAccess.new(self.as_json)
  end

  # Fetch an active postpone date for publication
  def biblreview_postponed_until
    postpone_date = postpone_dates.where(deleted_at: nil).where("postponed_until > (?)", DateTime.now).first
    if postpone_date
      return postpone_date.postponed_until
    else
      return nil
    end
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
      update_attributes(current_version_id: version.id)
      return true
    else
      version.errors.messages.each do |key, value|
        errors.add(key, value)
      end
      return false
    end
  end

  def set_postponed_until(postponed_until:, postponed_by:, epub_ahead_of_print: nil)
    postpone_dates.each do |postpone_object|
      if !postpone_object.deleted_at
        if !postpone_object.update_attributes(deleted_at: DateTime.now, deleted_by: postponed_by)
          return false
        end
      end
    end
    if !postpone_dates.create(postponed_until: postponed_until, created_by: postponed_by, updated_by: postponed_by)
      return false
    end
    if epub_ahead_of_print
      if !update_attribute(:epub_ahead_of_print, epub_ahead_of_print)
        return false
      end
    end
    return true
  end
end
