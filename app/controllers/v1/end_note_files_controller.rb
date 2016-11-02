class V1::EndNoteFilesController < V1::V1Controller

  #api :GET, '/end_note_files', 'Returns a list of EndNote files imported by the given user.'
  def index
    end_note_files = EndNoteFile.where(username: @current_user.username)
    @response[:end_note_files] = end_note_files.as_json
    render_json
  end

  #api :POST, '/end_note_files', 'Creates and returns an EndNoteFile object based on data imported from uploades EndNote file.'
  def create
    infile = params[:file]
    file_name = infile.original_filename
    file_extension = Pathname.new(file_name).extname.downcase

    if '.xml' != file_extension
      error_msg(ErrorCodes::DATA_ACCESS_ERROR,"#{I18n.t "end_note_files.errors.file_format_not_allowed"}")
      render_json
      return
    end

    xml = infile.read
    end_note_file = EndNoteFile.new(xml: xml, username: @current_user.username)

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
    error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "end_note_files.errors.not_found"}: #{params[:end_note_file_id]}")
    render_json
  end

  #api :DELETE, '/end_note_files', 'Deletes the EndNoteFile object with the given id.'
  def destroy
    end_note_file = EndNoteFile.find_by_id(params[:id])

    if end_note_file
      end_note_file.deleted_at = now
      @response[:end_note_file] = end_note_file

    else
      error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "end_note_files.errors.not_found"}: #{params[:id]}")
      error_msg(ErrorCodes::OBJECT_ERROR, "Could not find EndNote file with id #{params[:id]}")
    end
    render_json

    error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "end_note_files.errors.not_found"}: #{params[:end_note_file_id]}")
    render_json
  end
end
