class V1::EndnoteFilesController < V1::V1Controller

  #api :GET, '/endnote_files', 'Returns a list of Endnote files imported by the given user.'
  def index
    endnote_files = EndnoteFile.where(username: @current_user.username).where(deleted_at: nil)
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
      @response[:endnote_file] = endnote_file.as_json
      # TODO: check whether we should return 201 as is normal after object creation in REST.
      render_json(200)
    else
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
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find Endnote file with id #{params[:id]}")
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
        endnote_file.update_attributes(deleted_at: DateTime.now)
        @response[:endnote_file] = endnote_file
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "endnote_files.errors.delete_error"}: #{params[:id]}")
      end
      render_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "endnote_files.errors.not_found"}: #{params[:id]}")
      render_json
    end
  end

end
