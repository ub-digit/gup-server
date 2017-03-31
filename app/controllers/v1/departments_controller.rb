class V1::DepartmentsController < ApplicationController
  before_filter :validate_access, except: [:index]

  api :GET, '/departments', 'Returns a list of all departments based on given parameters'
  param :year, :number, :desc => 'Limits the search to only include departments which were active during given year.'
  param :search_term, String, :desc => 'Filter list based on provided search string'
  def index
    department_list = Department.all
    if params[:year]
      department_list = department_list.where("start_year IS NULL OR start_year <= ?",params[:year].to_i).where("end_year IS NULL OR end_year >= ?",params[:year].to_i)
    end

    if params[:search_term].present?
      query = params[:search_term].downcase
      department_list = department_list
                       .where("lower(name_sv) LIKE (?) OR lower(name_en) LIKE (?)",
                              "%#{query}%",
                              "%#{query}%")
    end



    brief = params[:brief]
    if brief && brief == 'true'
      options = {brief: true}
    else
      options = {}
    end

    if I18n.locale == :en
      @response[:departments] = department_list.order(name_en: :asc).as_json(options)
    else
      @response[:departments] = department_list.order(name_sv: :asc).as_json(options)
    end

    render_json
  end

  api :PUT, '/departments/:id', 'Update one department'
  def update
    dep = Department.find_by_id(params[:id])
    if dep
      if dep.update_attributes(permitted_params_for_update)
        @response[:department] = dep.as_json
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "departments.errors.invalid"}: #{params[:id]}")
      end
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "departments.errors.not_found"}: #{params[:id]}")
    end
    render_json
  end

  api :POST, '/departments/', 'Create a department'
  def create
    dep = Department.new(permitted_params_for_create)
    if dep.save
      @response[:department] = dep.as_json
      render_json(201)
      return
    else
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "departments.errors.invalid"}", dep.errors.messages)
    end
    render_json
  end

  private
  def permitted_params_for_update
    params.require(:department).permit(:end_year)
  end

  def permitted_params_for_create
    params.require(:department).permit(:end_year, :start_year, :name_sv, :name_en, :faculty_id)
  end
end
