class V1::ReportsController < V1::V1Controller
  def create
    report = ReportView.all
    filters = params[:filter]
    columns = params[:columns]
    column_headers = ['count']
    
    if filters
      if filters[:start_year] && filters[:end_year]
        report = report
                 .where("year >= ?", filters[:start_year])
                 .where("year <= ?", filters[:end_year])
      end

      if filters[:publication_types]
        report = report.where("publication_type IN (?)", filters[:publication_types])
      end

      if filters[:faculty]
        report = report.where("faculty_id = ?", filters[:faculty])
      end
      
      if filters[:department]
        report = report.where("department_id = ?", filters[:department])
      end

      if filters[:person]
        report = report.where("person_id = ?", filters[:person])
      end
    end

    if columns.present?
      column_headers = columns + column_headers
      
      select_string = columns.join(",")
      report = report.group(select_string)
      report = report.select(select_string + ",count(*)")
      report = report.order(columns)
      data = report.as_json(matrix: column_headers)
    else
      report = report.distinct
      data = [[report.count]]
    end
    
    @response['report'] = {
      columns: column_headers,
      data: data
    }
    render_json
  end
end
