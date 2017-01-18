# coding: utf-8
class V1::BiblreviewPublicationsController < V1::V1Controller
  include PaginationHelper

  api :GET, '/biblreview_publications', 'Returns a list of publications which are eligible for bibliographic review based on current filtering options'
  def index

    if @current_user.has_right?('biblreview')
      postponed_publication_ids = PostponeDate
      .where(deleted_at: nil)
      .where("postponed_until > (?)", DateTime.now)
      .select(:publication_id)
      if params[:only_delayed] && params[:only_delayed] == 'true'
        # Show only delayed publications
        publications = Publication
        .non_deleted
        .published
        .unbiblreviewed
        .where(id: postponed_publication_ids)
      else
        publications = Publication
        .non_deleted
        .published
        .unbiblreviewed
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
          publications = publications.start_year(Time.now.year)
        when "-1"
          publications = publications.end_year(Time.now.year-5)
        when "0"
          # publications=publication
        else
          publications = publications.year(params[:pubyear].to_i)
        end
      end
    end

    if params[:pubtype].present?
      publications = publications.publication_type(params[:pubtype].to_i)
    end
    if params[:faculty] && params[:faculty] != ''
      publications = publications.faculty_id(params[:faculty].to_i)
    end
    # ------------------------------------------------------------ #
    # FILTERS BLOCK END
    # ------------------------------------------------------------ #

    @response = generic_pagination(resource: publications, resource_name: 'publications', page: params[:page], additional_order: "publications.updated_at desc", options: {include_authors: true, brief: true})

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
