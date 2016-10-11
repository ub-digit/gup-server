# coding: utf-8
class V1::BiblreviewPublicationsController < V1::V1Controller
  include PaginationHelper
  
  api :GET, '/biblreview_publications', 'Returns a list of publications which are eligible for bibliographic review based on current filtering options'
  def index

    if @current_user.has_right?('biblreview')
      unreviewed_publication_version_ids = PublicationVersion
      .where(biblreviewed_at: nil)
      .where('pubyear > 2012')
      .select(:id)
      unreviewed_publication_ids = Publication
      .where(current_version_id: unreviewed_publication_version_ids)
      .select(:id)
      postponed_publication_ids = PostponeDate
      .where(deleted_at: nil)
      .where("postponed_until > (?)", DateTime.now)
      .select(:publication_id)
      if params[:only_delayed] && params[:only_delayed] == 'true'
        # Show only delayed publications
        publications = Publication
        .where(deleted_at: nil)
        .where.not(published_at: nil)
        .where(id: unreviewed_publication_ids)
        .where(id: postponed_publication_ids)
      else
        publications = Publication
        .where(deleted_at: nil)
        .where.not(published_at: nil)
        .where(id: unreviewed_publication_ids)
        .where.not(id: postponed_publication_ids)
      end
    else
      #return error TBD
      publications = Publication.none
    end

    # ------------------------------------------------------------ #
    # FILTERS BLOCK START
    # ------------------------------------------------------------ #
    if params[:pubyear]  != 'alla år'
      if params[:pubyear] && params[:pubyear] != ''
        case params[:pubyear]
        when "1"
          pubyear_ids = PublicationVersion
          .where("pubyear >= ?", Time.now.year)
          .select(:publication_id)
          publications = publications.where(id: pubyear_ids)
        when "-1"
          pubyear_ids = PublicationVersion
          .where("pubyear <= ?", Time.now.year-5)
          .select(:publication_id)
          publications = publications.where(id: pubyear_ids)
        when "0"
          # publications=publication
        else
          pubyear_ids = PublicationVersion
          .where("pubyear = ?", params[:pubyear].to_i)
          .select(:publication_id)
          publications = publications.where(id: pubyear_ids)
        end
      end
    end

    if params[:pubtype].present?
      publication_type_ids = PublicationVersion
      .where(publication_type_id: params[:pubtype])
      .select(:publication_id)
      publications = publications.where(id: publication_type_ids)
    end
    if params[:faculty] && params[:faculty] != ''
      departments_within_faculty = Department.where(faculty_id: params[:faculty]).select(:id)
      affiliations_for_departments = Departments2people2publication
      .where(department_id: departments_within_faculty)
      .select(:people2publication_id)
      publication_versions_from_faculty = People2publication
      .where(id: affiliations_for_departments)
      .select(:publication_version_id)
      publication_ids = PublicationVersion
      .where(id: publication_versions_from_faculty)
      .select(:publication_id)
      publications = publications.where(id: publication_ids)
    end
    # ------------------------------------------------------------ #
    # FILTERS BLOCK END
    # ------------------------------------------------------------ #

    @response = generic_pagination(resource: publications, resource_name: 'publications', page: params[:page], additional_order: "updated_at desc")

    render_json
  end

  api :PUT, '/biblreview_publications/:id', 'Sets given publication as bibliographically reviewed for its current version '
  def update
    if !@current_user.has_right?('biblreview')
      error_msg(ErrorCodes::PERMISSION_ERROR, "#{I18n.t "publications.errors.cannot_review_bibl"}")
      render_json
      return
    end

    id = params[:id]
    publication = Publication.find_by_id(id)

    if !publication.present?
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publications.errors.not_found"}: #{params[:id]}")
      render_json
      return
    end

    if !publication.is_published?
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publications.errors.cannot_review_bibl"}")
      render_json
      return
    end

    if publication.current_version.update_attributes(biblreviewed_at: DateTime.now, biblreviewed_by: @current_user.username) && publication.update_attributes(epub_ahead_of_print: nil)
      @response[:publication] = publication.as_json
      render_json
    else
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.cannot_review_bibl"}")
      render_json
    end
  end
end
