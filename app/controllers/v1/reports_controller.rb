class V1::ReportsController < V1::V1Controller
  def create
    report = ReportView.all
    filters = params[:filter]
    columns = params[:columns]
    
    if filters
      if filters[:start_year]
        report = report.where("year >= ?", filters[:start_year])
      end

      if filters[:end_year]
        report = report.where("year <= ?", filters[:end_year])
      end

      if filters[:publication_types]
        report = report.where("publication_type IN (?)", filters[:publication_types])
      end

      if filters[:faculties]
        report = report.where("faculty_id IN (?)", filters[:faculties])
      end
      
      if filters[:departments]
        report = report.where("department_id IN (?)", filters[:departments])
      end

      if filters[:persons]
        report = report.where("person_id IN (?)", filters[:persons])
      end
    end

    # If columns are requested, group by all columns, and calculate
    # a sum for each group. There cannot be a situation where a column
    # should be added but not grouped (SQL doesn't work that way)
    if columns.present?
      column_headers = columns + ['count']
      
      select_string = columns.join(",")
      report = report.group(select_string)
      report = report.select(select_string + ",count(*)")
      report = report.order(columns)
      data = report.as_json(matrix: column_headers)
    else
      column_headers = ['count']
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
