class Publication < ActiveRecord::Base
  has_many :publication_versions
  has_many :postpone_dates
  has_many :asset_data, class_name: "AssetData"
  has_one :endnote_record
  belongs_to :current_version, class_name: "PublicationVersion", foreign_key: "current_version_id"
  has_many :departments, :through => :current_version

  belongs_to :publications_view, class_name: "PublicationsView", foreign_key: "id"

  #scope :department_id, -> (department_id) { includes(:departments).where(:'departments.id' => department_id) }
  #scope :faculty_id, -> (faculty_id) { includes(:departments).where(:'departments.faculty_id' => faculty_id) }
  #TODO: year/pubyear inconsistenty, fix in reports?
  scope :source_name, -> (source_name) do
    includes({
      :current_version => {
        :people2publications => {
          :person => {
            :identifiers => :source
          }
        }
      }
    }).where(:'sources.name' => source_name)
  end


  #scope :non_external, -> { joins(current_version: {people2publications: {departments2people2publications: :department}})
  #      .where("departments.is_internal IS true").distinct}
  scope :non_external, -> { where(id: Publication.joins(current_version: {people2publications: {departments2people2publications: :department}})
        .where("departments.is_internal IS true").distinct.select(:id))}

  #scope :unbiblreviewed, -> { joins(:current_version).where('publication_versions.biblreviewed_at is null').where('publication_versions.pubyear > 2012') }

  scope :unbiblreviewed, -> { joins(current_version: {people2publications: {departments2people2publications: :department}})
        .where('publication_versions.biblreviewed_at is null')
        .where('publication_versions.pubyear > 2012')
        .where("departments.is_internal IS true").distinct }

  scope :non_deleted, -> { where(deleted_at: nil) }
  scope :published, -> { where.not(published_at: nil) }
  scope :year, -> (years) { includes(:current_version).where(:'publication_versions.pubyear' => years) }
  scope :start_year, -> (year) { joins(:current_version).where('publication_versions.pubyear >= ?', year) }
  scope :end_year, -> (year) { joins(:current_version).where('publication_versions.pubyear <= ?',  year) }
  #TODO publication_type vs department_id inconsistency, fix in reports?
  scope :publication_type, -> (publication_types) do
    includes(:current_version)
      .where(:'publication_versions.publication_type_id' => publication_types)
  end
  scope :ref_value, -> (ref_values) do
    # Hack of the century, but don't think there is any better way (OTHER defined in report_view view)
    #
    # CASE pv.ref_value
    #   WHEN 'ISREF'::text THEN 'ISREF'::text
    #   ELSE 'OTHER'::text
    #
    if ref_values.is_a? String and ref_values == 'OTHER'
      includes(:current_version).where.not(:'publication_versions.ref_value' => 'ISREF')
    else
      includes(:current_version).where(:'publication_versions.ref_value' => ref_values)
    end
  end
  scope :faculty_id, -> (faculty_ids) do
    includes({:current_version => {:people2publications => {:departments2people2publications => :department}}})
      .where(:'departments.faculty_id' => faculty_ids)
  end
  scope :department_id, ->(department_ids) do
    includes({:current_version => {:people2publications => :departments2people2publications}})
      .where(:'departments2people2publications.department_id' => department_ids + Department.where(parentid: department_ids).select(:id) + Department.where(grandparentid: department_ids).select(:id))
  end
  scope :person_id, ->(person_ids) do
    includes({:current_version => :people2publications})
      .where(:'people2publications.person_id' => person_ids)
  end
  scope :serie_id, ->(serie_ids) do
    includes({:current_version => :series2publications})
      .where(:'series2publications.serie_id' => serie_ids)
  end
  scope :project_id, ->(project_ids) do
    includes({:current_version => :projects2publications})
      .where(:'projects2publications.project_id' => project_ids)
  end

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

  def current_process_state
    return "PREDRAFT" if self.is_predraft?
    return "DRAFT" if self.is_draft?
    return "PUBLISHED"
  end

  def as_json(options = {})
    result = super

    selected_version = options[:version]
    if(selected_version)
      result.merge!(options[:version].as_json)
    else
      result.merge!(current_version.as_json(options))
    end

    if !options[:brief]
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
      result[:biblreview_postponed_comment] = biblreview_postponed_comment

      result[:files] = files(current_xaccount: options[:current_xaccount])
    end
    result
  end


  def update_search_engine
    # Update index on delete only here
    if self.is_published? && self.deleted_at
      PublicationSearchEngine.delete_from_search_engine(self.id)
      # Also update index for all authors to this publication, only current version
      PeopleSearchEngine.update_search_engine(self.current_version.authors)
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
      return true if ad.is_viewable?(param_tmp_token: "dummy")
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

  def biblreview_postponed_comment
    postpone_date = postpone_dates.where(deleted_at: nil).where("postponed_until > (?)", DateTime.now).first
    if postpone_date
      return postpone_date.comment
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

  def set_postponed_until(postponed_until:, postponed_by:, epub_ahead_of_print: nil, comment:nil)
    postpone_dates.each do |postpone_object|
      if !postpone_object.deleted_at
        if !postpone_object.update_attributes(deleted_at: DateTime.now, deleted_by: postponed_by)
          return false
        end
      end
    end
    if !postpone_dates.create(postponed_until: postponed_until, created_by: postponed_by, updated_by: postponed_by, comment: comment)
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
      duplicates = PublicationIdentifier.where(["lower(identifier_code) LIKE lower(?) and lower(identifier_value) LIKE lower(?)", publication_identifier[:identifier_code], publication_identifier[:identifier_value]]).select(:publication_version_id)
      duplicate_publications = Publication.where(deleted_at: nil).where.not(published_at: nil).where(current_version_id: duplicates)

      duplicate_publications.each do |duplicate_publication|
        duplication_object = {
          identifier_code: publication_identifier[:identifier_code],
          identifier_value: publication_identifier[:identifier_value],
          publication_id: duplicate_publication.id,
          publication_version_id: duplicate_publication.current_version.id,
          publication_title: duplicate_publication.current_version.title
        }
        unless publication_identifier_duplicates.map{|dupos| dupos[:publication_id]}.include?(duplicate_publication.id)
          publication_identifier_duplicates << duplication_object
        end
      end
    end
    return publication_identifier_duplicates
  end

  def self.has_duplicates?(publication_identifiers)
    duplicates = Publication.duplicates(publication_identifiers)
    return !duplicates.blank?
  end

end
