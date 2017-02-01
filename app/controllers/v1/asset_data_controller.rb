class V1::AssetDataController < V1::V1Controller
  before_filter :validate_access, except: [:show]
  before_filter :apply_access, only: [:show]

  ACCEPTED_FILE_TYPES = [".pdf", ".jpeg", ".jpg", ".doc", ".docx", ".xls", ".xlsx"]

  def create
    infile = params[:file]
    name = infile.original_filename
    extension = Pathname.new(name).extname.downcase

    if !ACCEPTED_FILE_TYPES.include?(extension)
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "asset_data.errors.file_format_not_allowed"}")
      render_json
      return
    end

    publication = Publication.find_by_id(params[:publication_id])
    if publication
      visible_after = params[:visible_after]
      content_type = infile.content_type
      tmp_token = Digest::MD5.hexdigest(Time.now.to_s + rand.to_s)
      checksum = Digest::MD5.hexdigest(name + Time.now.to_s + rand.to_s)
      asset_data = publication.asset_data.build(name: name, content_type: content_type, tmp_token: tmp_token, visible_after: visible_after, checksum: checksum, accepted: nil, created_by: @current_user.username)
      upload_dir = get_file_path(checksum)
      FileUtils.mkdir_p(upload_dir)
      File.open("#{upload_dir}/#{checksum}#{extension}", "wb") do |file|
        file.write(infile.read)
      end
      if publication.save
        @response[:asset_data] = asset_data.as_json
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "asset_data.errors.create_error"}: #{params[:publication_id]}")
      end
      render_json
      return
    end
    error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.not_found"}: #{params[:publication_id]}")
    render_json
  end

  def show
    asset_data = AssetData.find_by_id(params[:id])
    if asset_data
      tmp_token = params[:tmp_token]
      if asset_data.is_viewable_by_user?(param_tmp_token: tmp_token, xaccount: @current_user.username)
        dir_path = get_file_path(asset_data.checksum)
        extension = Pathname.new(asset_data.name).extname
        file_path = "#{dir_path}/#{asset_data.checksum}#{extension}"
        if File.exist?(file_path)
          send_file file_path, filename: asset_data.name, type: asset_data.content_type, disposition: 'inline'
          return
        else
          error_msg(ErrorCodes::DATA_ACCESS_ERROR,"#{I18n.t "asset_data.errors.file_not_found"}: #{params[:id]}")
          render_json
          return
        end
      else
        error_msg(ErrorCodes::PERMISSION_ERROR,"#{I18n.t "asset_data.errors.cannot_show_file"}: #{params[:id]}")
        render_json
        return
      end
    end
    error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "asset_data.errors.not_found"}: #{params[:id]}")
    render_json
  end

  def update
    accepted = params[:asset_data][:accepted]

    if accepted.nil?
      error_msg(ErrorCodes::VALIDATION_ERROR, I18n.t("asset_data.errors.terms_not_accepted_error"))
      render_json
      return
    end

    asset_data = AssetData.find_by_id(params[:id])
    if asset_data
      if asset_data.update_attributes(params.require(:asset_data).permit(:accepted, :visible_after))
        @response[:asset_data] = asset_data.as_json(except: [:tmp_token])
        render_json
        return
      else
        error_msg(ErrorCodes::VALIDATION_ERROR,"#{I18n.t "asset_data.errors.update_error"}: #{params[:id]}")
        render_json
        return
      end
    end
    error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "asset_data.errors.not_found"}: #{params[:id]}")
    render_json
  end

  def destroy
    asset_data = AssetData.find_by_id(params[:id])
    if asset_data
      if asset_data.is_deletable_by_user?(xaccount: @current_user.username)
        if asset_data.update_attributes({deleted_at: DateTime.now, deleted_by: @current_user.username})
          dir_path = get_file_path(asset_data.checksum)
          extension = Pathname.new(asset_data.name).extname
          file_path = "#{dir_path}/#{asset_data.checksum}#{extension}"
          if File.exist?(file_path)
            FileUtils.rm(file_path)
          else
            error_msg(ErrorCodes::DATA_ACCESS_ERROR,"#{I18n.t "asset_data.errors.file_not_found"}: #{params[:id]}")
          end
          render_json
          return
        end
        error_msg(ErrorCodes::VALIDATION_ERROR,"#{I18n.t "asset_data.errors.delete_error"}: #{params[:id]}")
        render_json
        return
      end
      error_msg(ErrorCodes::PERMISSION_ERROR,"#{I18n.t "asset_data.errors.delete_error"}: #{params[:id]}")
      render_json
      return
    end
    error_msg(ErrorCodes::OBJECT_ERROR, "#{I18n.t "asset_data.errors.not_found"}: #{params[:id]}")
    render_json
  end

private
  def get_file_path checksum
    APP_CONFIG['file_upload_root_dir'] + "/" + checksum[0..1] + "/" + checksum[2..3]
  end
end
