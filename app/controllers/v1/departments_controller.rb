class V1::DepartmentsController < ApplicationController
  def index
    if I18n.locale == :en
      @response[:departments] = Department.all.order(name_en: :asc)
    else
      @response[:departments] = Department.all.order(name_sv: :asc)
    end
    render_json
  end
end
