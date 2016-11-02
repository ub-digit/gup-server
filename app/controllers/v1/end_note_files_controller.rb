class V1::EndNoteFilesController < V1::V1Controller

  #api :GET, '/end_note_files', 'Returns a list of EndNote files imported by the given user.'
  def index
    end_note_files = EndNoteFile.where(username: @current_user.username).where(deleted_at: nil)
    @response[:end_note_files] = end_note_files.as_json
    render_json
  end

  #api :POST, '/end_note_files', 'Creates and returns an EndNoteFile object based on data imported from uploades EndNote file.'
  def create
    infile = params[:file]
    filename = infile.original_filename
    filename_extension = Pathname.new(filename).extname.downcase

    if '.xml' != filename_extension
      error_msg(ErrorCodes::DATA_ACCESS_ERROR,"#{I18n.t "end_note_files.errors.file_format_not_allowed"}")
      render_json
      return
    end

    xml = infile.read
    end_note_file = EndNoteFile.new(xml: xml, username: @current_user.username, name: filename)

    if end_note_file.save
      @response[:end_note_file] = end_note_file.as_json
      # TODO: check whether we should return 201 as is normal after object creation in REST.
      render_json(200)
    else
      error_msg(ErrorCodes::VALIDATION_ERROR,"#{I18n.t "end_note_files.errors.create_error"}")
      render_json
    end
  end

  #api :GET, '/end_note_files', 'returns an EndNoteFile object with the given id.'
  def show
    end_note_file = EndNoteFile.find_by_id(params[:id])

    if end_note_file
      @response[:end_note_file] = end_note_file
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find EndNote file with id #{params[:id]}")
    end
    render_json
  end

  #api :PUT, '/end_note_files', 'returns an error since one cannot delete an EndNote file through this API.'
  def update
    error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "end_note_files.errors.not_found"}: #{params[:id]}")
    render_json
  end

  #api :DELETE, '/end_note_files', 'Deletes the EndNoteFile object with the given id.'
  def destroy
    end_note_file = EndNoteFile.find_by_id(params[:id])

    if end_note_file
      if end_note_file.username == @current_user.username
        end_note_file.update_attributes(deleted_at: DateTime.now)
        @response[:end_note_file] = end_note_file
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "end_note_files.errors.delete_error"}: #{params[:id]}")
      end
      render_json
    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "end_note_files.errors.not_found"}: #{params[:id]}")
      render_json
    end
  end

end
