class V1::EndnoteFilesController < V1::V1Controller

  #api :GET, '/endnote_files', 'Returns a list of Endnote files imported by the given user.'
  def index
    endnote_files = EndnoteFile.where(username: @current_user.username)
    @response[:endnote_files] = endnote_files.as_json
    render_json
  end

  #api :POST, '/endnote_files', 'Creates and returns an EndnoteFile object based on data imported from uploades Endnote file.'
  def create
    infile = params[:file]
    filename = infile.original_filename
    filename_extension = Pathname.new(filename).extname.downcase

    if '.xml' != filename_extension
      error_msg(ErrorCodes::VALIDATION_ERROR,"#{I18n.t "endnote_files.errors.file_format_not_allowed"}")
      render_json
      return
    end

    xml = infile.read
    endnote_file = EndnoteFile.new(xml: xml, username: @current_user.username, name: filename)

    if endnote_file.save
      #pp '-*- EndnoteFileController.create - successfully stored simple EndnoteFile object -*-'
      endnote_file = handle_file_content(endnote_file)
      @response[:endnote_file] = endnote_file.as_json
      #pp '-*- EndnoteFileController.create produced json response-*-'
      render_json(201)
    else
      #pp '-*- EndnoteFileController.create An error - did NOT store EndnoteFile object -*-'
      error_msg(ErrorCodes::VALIDATION_ERROR,"#{I18n.t "endnote_files.errors.create_error"}")
      render_json
    end
  end

  #api :GET, '/endnote_files', 'returns an EndnoteFile object with the given id.'
  def show
    endnote_file = EndnoteFile.find_by_id(params[:id])

    if endnote_file
      @response[:endnote_file] = endnote_file
    else
      error_msg(ErrorCodes::OBJECT_ERROR,"#{I18n.t "endnote_files.errors.cannot_show_file"}: #{params[:id]}")
    end
    render_json
  end

  #api :PUT, '/endnote_files', 'returns an error since one cannot delete an Endnote file through this API.'
  def update
    error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "endnote_files.errors.not_found"}: #{params[:id]}")
    render_json
  end

  #api :DELETE, '/endnote_files', 'Deletes the EndnoteFile object with the given id.'
  def destroy
    endnote_file = EndnoteFile.find_by_id(params[:id])

    if endnote_file
      if endnote_file.username == @current_user.username
        #pp "Destroying endnote_file..."
        endnote_file.destroy
        #pp "Destroyed endnote_file... I hope."
        #@response[:endnote_file] = endnote_file
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "endnote_files.errors.delete_error"}: #{params[:id]}")
      end
      render_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "endnote_files.errors.not_found"}: #{params[:id]}")
      render_json
    end
  end

  def parse(xml)
    #pp '-*- EndnoteFileController.parse -*-'
    xml_obj = Nokogiri::XML(xml)
    if !xml_obj.errors.empty?
      puts "Somethings wrong with the file: #{xml_obj.errors}"
    else
      EndnoteRecord.parse(xml_obj)
    end
  end

  def handle_file_content endnote_file
    #pp '-*- EndnoteFileController.handle_file_content -*-'
    raw_xml = endnote_file.xml

    if raw_xml.blank?
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "endnote_files.errors.no_data_in_file"}")
      #render_json
      return
    end

    xml = Nokogiri::XML(raw_xml)
    if !xml.errors.empty?
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "endnote_files.errors.invalid_file"}", xml.errors)
      #render_json
      return
    end

    # check versions
    version_list = xml.search('//source-app').map do |element|
      element.attr("version").to_f
    end
    version_list = version_list.select! do |version|
      version < 8
    end
    if !version_list.empty?
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "endnote_files.errors.unsupported_endnote_version"}")
      #render_json
      return
    end

    #record_count = 0
    #record_total = 0

    xml.search('//xml/records/record').each do |record|
      #pp '-*- EndnoteFileController.handle_file_content creating record -*-'
      #record_total += 1

      # params[:publication] = {}
      endnote_record = EndnoteRecord.parse(record)
      endnote_record.username = @current_user.username
      endnote_record.xml = record
      endnote_record.checksum = Digest::MD5.hexdigest(record)
      #pp "TITLE: #{endnote_record.title}"
      #pp '==============================='
      #pp endnote_record
      #pp '==============================='
      #record2 = EndnoteRecord.where(checksum: endnote_record.checksum).where(username: @current_user.username)
      existing_record = EndnoteRecord.find_by(checksum: endnote_record.checksum)
      if existing_record
        #pp '-*- EndnoteFileController.handle_file_content - Record exists, adding it to file object -*-'
        endnote_file.endnote_records << existing_record
      else
        if endnote_record.save
          #record_count += 1
          #pp '-*- EndnoteFileController.handle_file_content adding record to file -*-'
          endnote_file.endnote_records << endnote_record
          #pp '-*- EndnoteFileController.handle_file_content record was added to file -*-'
        else
          #pp '-*- EndnoteFileController.handle_file_content record was not saved -*-'
          error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "endnote_files.errors.create_record_error"}", endnote_file.errors)
        end
      end
      #   record_count += 1
      #   if record_count == 1
      #     return_pub = pub
      #   end
      # else
      #   error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.update_error"}", pub.errors)
      #   render_json
      #   return
      # end
      #pp '-*- EndnoteFileController.handle_file_content done createing records -*-'
    end
    #pp '-*- EndnoteFileController.handle_file_content returning the file -*-'
    return endnote_file
    #@response[:endnote_file] = return_endnote_file
    #@response[:meta] = {result: {count: record_count, total: record_total}}
    #render_json(201)
  end

  def handle_file raw_xml
    #pp '-*- EndnoteFileController.handle_file -*-'
    if raw_xml.blank?
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "endnote_files.errors.no_data_in_file"}")
      render_json
      return
    end

    xml = Nokogiri::XML(raw_xml)
    if !xml.errors.empty?
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "endnote_files.errors.invalid_file"}", xml.errors)
      render_json
      return
    end

    # check versions
    version_list = xml.search('//source-app').map do |element|
      element.attr("version").to_f
    end
    version_list = version_list.select! do |version|
      version < 8
    end
    if !version_list.empty?
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "endnote_files.errors.unsupported_endnote_version"}")
      render_json
      return
    end

    record_count = 0
    record_total = 0
    return_pub = {}

    xml.search('//xml/records/record').each do |record|
      #pp '-*- EndnoteFileController.handle_file creating record -*-'
      record_total += 1
      # params[:publication] = {}
      # endnote = Endnote.parse(record)
      # if endnote
      #   params[:publication].merge!(endnote.as_json)
      # else
      #   params[:publication][:title] = "[Title not found]"
      # end

      # #create_basic_data
      # params[:publication][:deleted_at] = nil
      # params[:publication][:publication_type] = nil
      # params[:publication][:publanguage] ||= 'en'
      # #pub = Publication.new(permitted_params(params))
      # pub = Publication.new(params)
      # pub.process_state = 'PREDRAFT'
      # #pub.deleted_at = nil
      # #pub.publication_type = nil
      # #pub.publanguage ||= 'en'
      # if pub.save
      #   record_count += 1
      #   if record_count == 1
      #     return_pub = pub
      #   end
      # else
      #   error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.update_error"}", pub.errors)
      #   render_json
      #   return
      # end
    end
    @response[:publication] = return_pub
    @response[:meta] = {result: {count: record_count, total: record_total}}
    render_json(201)
  end

  #def create_basic_data
  #  params[:publication][:deleted_at] = nil
  #  params[:publication][:publication_type] = nil
  #  params[:publication][:publanguage] ||= 'en'
  #end


end
