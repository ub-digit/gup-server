class V1::DepartmentsController < ApplicationController
  def index
    @response[:departments] = Department.all
    render_json
  end
end
