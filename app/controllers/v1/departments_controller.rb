class V1::DepartmentsController < ApplicationController
  def index

    department_list = Department.all
  	if params[:year] 
  	  department_list = department_list.where("start_year < ?",params[:year].to_i).where("end_year > ?",params[:year].to_i)
    end
    
    if I18n.locale == :en
      @response[:departments] = department_list.order(name_en: :asc)
    else
      @response[:departments] = department_list.order(name_sv: :asc)
    end
    render_json
  end
end
