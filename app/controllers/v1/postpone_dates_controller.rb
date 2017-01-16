class V1::PostponeDatesController < V1::V1Controller
  api :POST, '/postpone_dates'
  desc 'Postpones a publication for bibliographically review at a later date.' 
  def create
    if !@current_user.has_right?('biblreview')
      error_msg(ErrorCodes::PERMISSION_ERROR, "#{I18n.t "publications.errors.cannot_delay_bibl_review_time"}")
      render_json
      return
    end

    postpone_date = params[:postpone_date]

    if !postpone_date
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publications.errors.no_data"}")
      render_json
      return
    end

    id = postpone_date[:publication_id]
    publication = Publication.find_by_id(id)
    
    if !publication.present?
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publications.errors.not_found"}: #{postpone_date[:publication_id]}")
      render_json
      return
    end

    if publication.published_at.nil?
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "publications.errors.cannot_delay_bibl_review_time"}")
      render_json
      return
    end
    
    if postpone_date[:postponed_until].blank? || !is_date_valid?(postpone_date[:postponed_until])
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.cannot_delay_bibl_review_time_param_error"}: #{postpone_date[:publication_id]}")
      render_json
      return      
    end

    extra_params = {}
    # If comment is epub ahead of print, set specific flag
    if postpone_date[:comment] == "E-pub ahead of print"
      extra_params[:epub_ahead_of_print] = DateTime.now
    end

    if publication.set_postponed_until(postponed_until: Time.parse(postpone_date[:postponed_until]), 
                                       postponed_by: @current_user.username,
                                       epub_ahead_of_print: extra_params[:epub_ahead_of_print], comment:postpone_date[:comment])
      @response[:postpone_date] = publication.postpone_dates.first
      render_json
    else
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.cannot_delay_bibl_review_time"}")
      render_json
    end  

  end
  
  private
  def is_date_valid? date
    begin
      Time.parse(date)
    rescue 
      return false
    end
    return true
  end

end
