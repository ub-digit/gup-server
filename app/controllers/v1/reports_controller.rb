require 'spreadsheet'

class V1::ReportsController < V1::V1Controller
  def show
    #filename = params[:name]+".csv"
    #csv_data = generate_report(format: "csv")
    #send_data csv_data, :filename => filename, type: "test/csv", disposition: "attachment"
    filename = params[:name]+".xls"
    xls_data = generate_report(format: "xls")
    send_data xls_data.string.force_encoding('binary'), :filename => filename, type: "application/excel", disposition: "attachment"
  end

  def create
    @response['report'] = generate_report
    render_json
  end

  private
  def generate_report(format: "json")
    report = ReportView.all
    if params[:report]
      filters = params[:report][:filter]
      columns = params[:report][:columns]
    else
      filters = nil
      columns = nil
    end

    if filters
      if filters[:start_year].present?
        report = report.where("year >= ?", filters[:start_year])
      end

      if filters[:end_year].present?
        report = report.where("year <= ?", filters[:end_year])
      end

      if filters[:publication_types].present?
        report = report.where("publication_type_id IN (?)", filters[:publication_types])
      end

      if filters[:ref_value].present?
        report = report.where(ref_value: 'ISREF')
      end

      if filters[:faculties].present?
        report = report.where("faculty_id IN (?)", filters[:faculties])
      end

      if filters[:departments].present?
        report = report.where(department_id: filters[:departments] + Department.where(parentid: filters[:departments]).select(:id) + Department.where(grandparentid: filters[:departments]).select(:id))
      end

      if filters[:persons].present?
        report = report.where("xaccount IN (?)", filters[:persons])
      end
    end

    # If columns are requested, group by all columns, and calculate
    # a sum for each group. There cannot be a situation where a column
    # should be added but not grouped (SQL doesn't work that way)
    if columns.present?
      if ReportView.columns_valid?(columns)
        column_headers = columns + ['count']

        select_string = columns.join(",")
        report = report.group(select_string)
        report = report.select(select_string + ",count(distinct(publication_id))")
        report = report.order(columns)
        data = report.as_json(matrix: column_headers)
      else
        error_msg(ErrorCodes::REQUEST_ERROR, "Invalid column")
        return
      end
    else
      column_headers = ['count']
      report = report.distinct
      data = [[report.count]]
    end

    column_headers = column_headers.map do |col|
      I18n.t('reports.columns.'+col.to_s)
    end

    report_data = {
      columns: column_headers,
      data: data
    }

    if format == "xls"
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet::Workbook.new
      sheet = book.create_worksheet(name: "GUP Statistics")

      column_headers.each_with_index do |column_header, index|
        sheet[0,index] = column_header
      end

      data.each_with_index do |row, rowindex|
        row.each_with_index do |value, colindex|
          sheet[rowindex+1,colindex] = value.is_a?(Array) ? value[0] : value
        end
      end

      require 'stringio'
      spreadsheet = StringIO.new
      book.write spreadsheet
      return spreadsheet
    end

    return report_data

    #if format == "csv"
    #  csv_data = column_headers.join("\t")+"\n"
    #  csv_data += data.map do |rows|
    #    rows.join("\t")
    #  end.join("\n")
    #  return csv_data
    #else
    #  return report_data
    #end
  end
end
