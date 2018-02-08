class V1::PublishedPublicationsController < ApplicationController
  before_filter :validate_access, except: [:index_public]
  before_filter :apply_access, only: [:index_public]
  include PaginationHelper

  api :GET, '/published_publications_xls', 'Returns an xls file with published publications based on filter parameters'
  def xls
    publications = Publication.all # Can remove join? Publication.all
    publications = apply_filters(publications)
    publications = publications.non_deleted.published
    # Since reports_view filters on source_name = 'xkonto', we must do the same
    # publications = publications.source_name('xkonto')

    # TODO: Perhaps support same sort parameters as index?
    # hardcoded order sucks
    publications = publications.order('publication_versions.title asc')

    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet(name: I18n.t('publications_xls.sheet_name'))
    [
      I18n.t('publications_xls.columns.id'),
      I18n.t('publications_xls.columns.title'),
      I18n.t('publications_xls.columns.authors_and_departments'),
      I18n.t('publications_xls.columns.publication_type'),
      I18n.t('publications_xls.columns.ref_value'),
      I18n.t('publications_xls.columns.publication_year'),
      I18n.t('publications_xls.columns.source_title'),
      I18n.t('publications_xls.columns.source_volume'),
      I18n.t('publications_xls.columns.source_issue'),
      I18n.t('publications_xls.columns.source_pages'),
      I18n.t('publications_xls.columns.issn'),
      I18n.t('publications_xls.columns.eissn'),
      I18n.t('publications_xls.columns.links'),
      I18n.t('publications_xls.columns.projects'),
      I18n.t('publications_xls.columns.keywords'),
      I18n.t('publications_xls.columns.identifiers')
    ].each_with_index do |column_header, column_index|
      sheet[0, column_index] = column_header
    end

    #TODO: Escape separators, and quote departments?
    publications.each_with_index do |publication, row_index|
      version = publication.current_version
      [
        # Id
        publication.id,
        # Title
        version.title,
        # Authors with departments
        authors_departments_column_value(version.people2publications),
        # Publication type name
        version.publication_type.present? ? version.publication_type.name : '',
        # Publication ref
        version.ref_value_name,
        # Puplication year
        version.pubyear,
        # Source title
        version.sourcetitle,
        # Source volumne
        version.sourcevolume,
        # Source issue
        version.sourceissue,
        # Source pages
        version.sourcepages,
        # ISSN
        version.issn,
        # EISSN
        version.eissn,
        # Links
        version.publication_links.map { |l| "#{l.url}" }.join('; '),
        # Project (TODO: format, include more data!?)
        version.projects.map { |p| "#{p.title}" }.join('; '),
        # Categories
        version.categories.map { |c| "#{c.name}" }.join('; '),
        # Keywords
        version.keywords,
        # Identifiers
        version.publication_identifiers.map { |i| "#{i.get_label}" }.join('; ')
      ].each_with_index do |value, column_index|
        sheet[row_index + 1, column_index] = value
      end
    end
    require 'stringio'
    spreadsheet = StringIO.new
    book.write spreadsheet

    filename_suffix = params[:name_suffix].present? ? params[:name_suffix] : ''
    filename = (params[:name].present? ? params[:name] : "GUP_" + DateTime.now.strftime("%Y-%m-%d_%H.%M")) + "#{filename_suffix}.xls"
    send_data spreadsheet.string.force_encoding('binary'), :filename => filename, type: "application/excel", disposition: "attachment"
  end


  api :GET, '/published_publications', 'Returns a list of published publications based on filter parameters'
  def index
    # Initialize filter parameters
    actor = params[:actor]
    registrator = params[:registrator]

    # If no parameters are given, default to setting actor as current_user
    if actor.nil? && registrator.nil?
      actor = 'logged_in_user'
    end

    # Get publication selection
    publications = get_publications

    # Get sort order params
    sort_order = get_sort_order

    if actor == 'logged_in_user'
      if @current_user.person_ids
        publications = publications.where('current_version_id in (?)', People2publication.where('person_id IN (?)', @current_user.person_ids).map { |p| p.publication_version_id})
      else
        publications = Publication.none
      end
    end

    if registrator == 'logged_in_user'
      publications = publications.where('current_version_id in (?)', PublicationVersion.where('created_by = (?) or updated_by = (?)', @current_user.username, @current_user.username).map { |p| p.id})
    end

    @response = generic_pagination(resource: publications, resource_name: 'publications', page: params[:page], additional_order: sort_order, options: {include_authors: true, brief: true})
    render_json(200)
  end


  api :GET, '/publication_lists', 'Returns a list of published publications based on filter parameters'
  def index_public
    publications = get_publications

    # Get sort order params
    sort_order = get_sort_order

    @response = generic_pagination(resource: publications, resource_name: 'publications', page: params[:page], additional_order: sort_order, options: {include_authors: true, brief: true})
    render_json(200)
  end

  def get_publications
    # This joins is made just for get access to the sort fields
    publications = Publication.non_deleted.published.joins(:publications_view)

    publications = apply_filters(publications)

    return publications
  end

  api :POST, '/published_publications', 'Creates a published publication based on a draft object'
  def create
    draft_id = params[:publication][:draft_id]
    if draft_id
      publication = Publication.find_by_id(draft_id)
      if publication
        if publication.is_draft? || publication.is_predraft?
          publication.published_at = DateTime.now
          publish_publication(publication: publication)
        else
          error_msg(ErrorCodes::OBJECT_ERROR, "Publication with id #{draft_id} is not a draft")
          render_json
          return
        end
      else
        error_msg(ErrorCodes::OBJECT_ERROR, "Draft with id #{draft_id} does not exist")
        render_json
        return
      end
    else
      error_msg(ErrorCodes::REQUEST_ERROR, "No draft_id has been given")
      render_json
      return
    end
  end

  api :PUT, '/published_publications/:id', 'Updates a published publication'
  def update
    id = params[:id]
    publication = Publication.find_by_id(id)
    if publication
      if publication.is_published?
        publish_publication(publication: publication)
      else
        error_msg(ErrorCodes::OBJECT_ERROR, "Publication with id #{id} has not been published yet")
        render_json
        return
      end
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find publication with id #{id}")
      render_json
      return
    end
  end

  private

  def authors_departments_column_value(people2publications)
    people2publications.map do |p2p|
      person = p2p.person
      "\"#{person.first_name} #{person.last_name} (" << p2p.departments.map { |d| d.name }.join(', ') << ')"'
    end.join('; ')
  end

  def get_sort_order
    sort_by = params[:sort_by] || ''
    if sort_by.eql?("pubyear")
      order = "publications_views.pubyear desc, publications_views.updated_at desc"
    elsif sort_by.eql?("title")
      order = "publications_views.title asc, publications_views.updated_at desc"
    elsif sort_by.eql?("pubtype")
      order = "publications_views.label_#{I18n.locale.to_s} asc, publications_views.pubyear desc, publications_views.title asc, publications_views.updated_at desc"
    elsif sort_by.eql?("first_author")
      order = "publications_views.first_author_last_name asc, publications_views.pubyear desc, publications_views.title asc, publications_views.updated_at desc"
    else
      # pubyear should be default sort order?
      order = "publications_views.updated_at desc"
    end
    order
  end

  def apply_filters(publications)
    #TODO: Manage xkonto and orcid parameters
    publications = publications.where(:id => params[:publication_id].split(";")) if params[:publication_id].present?
    publications = publications.person_id(params[:person_id].split(";")) if params[:person_id].present?
    publications = publications.publication_type(params[:publication_type].split(";")) if params[:publication_type].present?
    publications = publications.department_id(params[:department_id].split(";")) if params[:department_id].present?
    publications = publications.faculty_id(params[:faculty_id].split(";")) if params[:faculty_id].present?
    publications = publications.serie_id(params[:serie_id].split(";")) if params[:serie_id].present?
    publications = publications.project_id(params[:project_id].split(";")) if params[:project_id].present?
    publications = publications.year(params[:year].split(";")) if params[:year].present?
    publications = publications.ref_value(params[:ref_value]) if params[:ref_value].present?
    if params[:start_year].present? and params[:start_year].is_a? String and params[:start_year].to_i.to_s == params[:start_year]
      publications = publications.start_year(params[:start_year].to_i)
    end
    if params[:end_year].present? and params[:end_year].is_a? String and params[:end_year].to_i.to_s == params[:end_year]
      publications = publications.end_year(params[:end_year].to_i)
    end
    publications
  end

  def publish_publication(publication:)

    if publication
      publication_version_old = publication.current_version
      params[:publication] = publication.attributes_indifferent.merge(params[:publication])
      params[:publication][:created_by] = publication_version_old.created_by
      params[:publication][:updated_by] = @current_user.username

      # Reset the bibl review info
      params[:publication][:biblreviewed_at] = nil
      params[:publication][:biblreviewed_by] = nil
      params[:publication][:biblreview_postponed_until] = DateTime.now
      params[:publication][:biblreview_postpone_comment] = nil

      if params[:publication][:epub_ahead_of_print]
        publication.epub_ahead_of_print = DateTime.now
      else
        publication.epub_ahead_of_print = nil
      end

      Publication.transaction do
        if !params[:publication][:publication_type_id]
          publication_version_new = publication.build_version(permitted_params(params))
        else
          publication_type = PublicationType.find_by_id(params[:publication][:publication_type_id])
          if publication_type.present?
            publication_version_new = publication.build_version(publication_type_permitted_params(publication_type: publication_type, params: params))
          else
            error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.unknown_publication_type"}: #{params[:publication][:publication_type]}")
            render_json
            raise ActiveRecord::Rollback
          end
        end
        publication_version_new.author = params[:publication][:authors]

        if publication.save_version(version: publication_version_new)
          if params[:publication][:project].present?
            params[:publication][:project].each do |project|
              Projects2publication.create(publication_version_id: publication_version_new.id, project_id: project)
            end
          end
          if params[:publication][:series].present?
            params[:publication][:series].each do |serie|
              Series2publication.create(publication_version_id: publication_version_new.id, serie_id: serie)
            end
          end
          if params[:publication][:category_hsv_local].present?
            params[:publication][:category_hsv_local].each do |category|
              Categories2publication.create(publication_version_id: publication_version_new.id, category_id: category)
            end
          end
          create_publication_identifiers(publication_version: publication_version_new)
          create_publication_links(publication_version: publication_version_new)

          if params[:publication][:authors].present?
            params[:publication][:authors].each_with_index do |author, index|
              oldp2p = People2publication.where(person_id: author[:id], publication_version_id: publication_version_old.id).first
              new_reviewed_at = nil
              new_reviewed_publication_version_id = publication_version_new.id
              if oldp2p
                new_reviewed_at = oldp2p.reviewed_at

                reviewed_p2p = nil
                # If last review date is nil and review has occured before, set review date to previous review date.
                if oldp2p.reviewed_at.nil? && oldp2p.reviewed_publication_version_id.present?
                  reviewed_p2p = People2publication.where(person_id: author[:id], publication_version_id: oldp2p.reviewed_publication_version_id).first
                  new_reviewed_at = reviewed_p2p.reviewed_at
                end
                if oldp2p.reviewed_publication_version_id.present?
                  # Check if publication object is different
                  if publication_version_new.review_diff(oldp2p.reviewed_publication_version).present?
                    new_reviewed_at = nil
                    new_reviewed_publication_version_id = oldp2p.reviewed_publication_version_id
                  end

                  # Use revewd_p2p if it exists, otherwise use oldp2p for comparison
                  p2p_to_compare_with = oldp2p
                  if reviewed_p2p.present?
                    p2p_to_compare_with = reviewed_p2p
                  end

                  # Check if affiliations are different
                  if p2p_to_compare_with.departments2people2publications.blank? || author[:departments].blank?

                    new_reviewed_at = nil
                    new_reviewed_publication_version_id = oldp2p.reviewed_publication_version_id
                  else

                    old_affiliations = p2p_to_compare_with.departments2people2publications.map {|x| x.department_id}
                    new_affiliations = author[:departments].map {|x| x[:id].to_i}
                    unless (old_affiliations & new_affiliations == old_affiliations) && (new_affiliations & old_affiliations == new_affiliations)
                      new_reviewed_at = nil
                      new_reviewed_publication_version_id = oldp2p.reviewed_publication_version_id
                    end
                  end
                end
              end
            create_affiliation(publication_version_id: publication_version_new.id, person: author, position: index+1, reviewed_at: new_reviewed_at, reviewed_publication_version_id: new_reviewed_publication_version_id)
            end
          end

          @response[:publication] = publication.as_json
          @response[:publication][:authors] = people_for_publication(publication_version_id: publication_version_new.id)

          # Update search index for this publication
          PublicationSearchEngine.update_search_engine(publication)
          # Also update people search index for and all publication authors, for this publication version and old publication version
          PeopleSearchEngine.update_search_engine((publication.current_version.authors + publication_version_old.authors).uniq)
          if publication_version_new.datasource
            ImportManager.feedback_to_adapter(
              datasource: publication_version_new.datasource,
              sourceid: publication_version_new.sourceid,
              feedback_hash: {publication_id: publication.id})
          end
          render_json(200)
        else
          error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.publish_error"}", publication.errors)
          render_json
          raise ActiveRecord::Rollback
        end
      end
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publications.errors.not_found"}: #{params[:id]}")
      render_json
    end
  end

  def publication_identifier_permitted_params(params)
    params.require(:publication_identifier).permit(:publication_version_id, :identifier_code, :identifier_value)
  end

  def create_publication_identifiers(publication_version:)
    if params[:publication][:publication_identifiers]
      pis_errors = []
      params[:publication][:publication_identifiers].each do |publication_identifier|
        publication_identifier[:publication_version_id] = publication_version.id
        pi = PublicationIdentifier.new(publication_identifier_permitted_params(ActionController::Parameters.new(publication_identifier: publication_identifier)))
        if !pi.save
          pis_errors << [pi.errors]
        end
      end
      if !pis_errors.empty?
        error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publication_identifiers.errors.create_error"}", pis_errors)
        render_json
        raise ActiveRecord::Rollback
      end
    end
  end

  def create_publication_links(publication_version:)
    if params[:publication][:publication_links].present?
      params[:publication][:publication_links].each do |publication_link|
      #@TODO: if not params[:publication][:publication_links].kind_of?(Array) #respond_to?('each') #trow exception
        publication_link[:publication_version_id] = publication_version.id
        #TODO: publication_version.create_publication_link
        pl = PublicationLink.create(
          publication_link_permitted_params(
            ActionController::Parameters.new(publication_link: publication_link)
          )
        )
        if pl.errors.any?
          #TODO: Right now not correct field key in errors message (should be "publication_links")?
          error_msg(ErrorCodes::VALIDATION_ERROR, I18n.t("publication_links.errors.create_error"), pl.errors)
          render_json
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def publication_link_permitted_params(params)
    params.require(:publication_link).permit(:url, :position, :publication_version_id)
  end

  def permitted_params(params)
    permitted_fields = Field.all.pluck(:name) + global_params
    permitted_fields.delete("epub_ahead_of_print")
    permitted_fields.delete(:epub_ahead_of_print)
    permitted_fields.delete("project")
    permitted_fields.delete(:project)
    permitted_fields.delete("series")
    permitted_fields.delete(:series)
    params.require(:publication).permit(permitted_fields)
  end

  def publication_type_permitted_params(publication_type:, params:)
    permitted_fields = publication_type.permitted_fields + global_params
    permitted_fields.delete("epub_ahead_of_print")
    permitted_fields.delete(:epub_ahead_of_print)
    permitted_fields.delete("project")
    permitted_fields.delete(:project)
    permitted_fields.delete("series")
    permitted_fields.delete(:series)
    params.require(:publication).permit(permitted_fields)
  end

  # Params which are not defined by publication type
  def global_params
    [:publication_type_id, :is_draft, :is_deleted, :created_at, :created_by, :updated_by, :biblreviewed_at, :biblreviewed_by, :bibl_review_postponed_until, :bibl_review_postpone_comment, :content_type, :xml, :datasource, :sourceid, :ref_value]
  end

  # Creates connections between people, departments and mpublications for a publication and a people array
  def create_affiliation (publication_version_id:, person:, position:, reviewed_at: nil, reviewed_publication_version_id: nil)
    p2p = {person_id: person[:id], position: position, departments2people2publications: person[:departments]}
    p2p_obj = People2publication.create({publication_version_id: publication_version_id, person_id: p2p[:person_id], position: position, reviewed_at: reviewed_at, reviewed_publication_version_id: reviewed_publication_version_id})
    department_list = p2p[:departments2people2publications]
    if department_list.present?
      department_list.each.with_index do |d2p2p, j|
        Departments2people2publication.create({people2publication_id: p2p_obj.id, department_id: d2p2p[:id], position: j + 1})
      end
    end
  end

  # Returns collection of people including departments for a specific Publication
  def people_for_publication(publication_version_id:)
    p2ps = People2publication.where(publication_version_id: publication_version_id).order(position: :asc)
    people = p2ps.map do |p2p|
      person = Person.where(id: p2p.person_id).first.as_json
      department_ids = Departments2people2publication.where(people2publication_id: p2p.id).order(updated_at: :desc).select(:department_id)

      departments = Department.where(id: department_ids)
      person['departments'] = departments.as_json

      presentation_string = Person.where(id: p2p.person_id).first.presentation_string(departments.map{|d| I18n.locale == :en ? d.name_en : d.name_sv}.uniq[0..1])
      person['presentation_string'] = presentation_string

      person
    end

    return people
  end

end
