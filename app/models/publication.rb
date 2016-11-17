class Publication < ActiveRecord::Base
  has_many :publication_versions
  has_many :postpone_dates
  has_many :asset_data, class_name: "AssetData"
  has_one :endnote_record

  belongs_to :current_version, class_name: "PublicationVersion", foreign_key: "current_version_id"

  nilify_blanks :types => [:text]

  after_save :update_search_engine, on: :update

  def is_predraft?
    process_state == "PREDRAFT"
  end

  def is_draft?
    process_state == "DRAFT"
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
      result.merge!(current_version.as_json(include_authors: options[:include_authors]))
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
    result[:files] = files(current_xaccount: options[:current_xaccount])
    result
  end


  def update_search_engine
    # Update index on delete only here
    if self.is_published? && self.deleted_at
      PublicationSearchEngine.delete_from_search_engine(self.id)
    end
  end

  # Used for cloning an existing post
  def attributes_indifferent
    ActiveSupport::HashWithIndifferentAccess.new(self.as_json)
  end

  def files(current_xaccount: nil)
    file_list = []
    asset_data.each do |ad|
      next if !ad.deleted_at.nil?
      next if ad.accepted.nil?
      entry = {id: ad.id, name: ad.name, content_type: ad.content_type}
      if ad.visible_after && ad.visible_after >= Date.today
        entry[:visible_after] = ad.visible_after
      end
      if ad.is_deletable_by_user?(xaccount: current_xaccount)
        entry[:deletable] = true
      end
      file_list << entry
    end
    file_list
  end

  def has_viewable_file?
    asset_data.each do |ad|
      return true if ad.is_viewable? "dummy"
    end
    return false
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
  # Process State is always "PREDRAFT" in this case, because there was not
  # publication before, and it has not yet been saved by a user. It will be set
  # when a save of the first version has been successful.
  def save_new
    Publication.transaction do
      if(save)
        if(!save_version(version: current_version, process_state: "PREDRAFT"))
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
  # The publication object will also be updated with a process_state that
  # can be either "DRAFT" or "PUBLISHED". This will only happen if saving
  # the version was successful.
  def save_version(version:, process_state: "UNKNOWN")
    version.created_at = Time.now
    if version.save
      update_attributes(current_version_id: version.id)
      update_attributes(process_state: process_state)
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

  def to_oai_dc
    OaiDocuments::DC.create_record self
  end

  def to_mods
    OaiDocuments::MODS.create_record self
  end

  #
  # Takes a list of publication_identifier objects
  # and checks for duplicates among all persisted publications,
  # returns an array with objects with info about the duplications
  #
  def self.duplicates(publication_identifiers)
    publication_identifier_duplicates = []
    publication_identifiers.each do |publication_identifier|
      duplicates = PublicationIdentifier.where(identifier_code: publication_identifier[:identifier_code], identifier_value: publication_identifier[:identifier_value]).select(:publication_version_id)
      duplicate_publications = Publication.where(deleted_at: nil).where.not(published_at: nil).where(current_version_id: duplicates)
      duplicate_publications.each do |duplicate_publication|
        duplication_object = {
          identifier_code: publication_identifier[:identifier_code],
          identifier_value: publication_identifier[:identifier_value],
          publication_id: duplicate_publication.id,
          publication_version_id: duplicate_publication.current_version.id,
          publication_title: duplicate_publication.current_version.title
        }
        publication_identifier_duplicates << duplication_object
      end
    end
    return publication_identifier_duplicates
  end

end
