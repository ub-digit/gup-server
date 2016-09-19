class V1::AssetDataController < V1::V1Controller
  UPLOAD_ROOT = "var/tmp/gup_asset"

  def create
    infile = params[:file]
    name = infile.original_filename
    content_type = infile.content_type
    publication = Component.find(params[:publication_id])
    if publication
      upload_root = UPLOAD_ROOT
      asset_data = publication.asset_data.build(name: name, content_type: content_type)
      upload_dir = "#{upload_root}/#{asset_data.upload_dir}"
      FileUtils.mkdir_p(upload_dir)
      File.open("#{upload_dir}/#{name}", "wb") do |file|
        file.write(infile.read)
      end
      if publication.save
        render json: {}
        return
      end
    end
    render json: {}
  end
  
  def show
    asset_data = AssetData.find(params[:id])
    upload_root = UPLOAD_ROOT
    dir_path = "#{upload_root}/#{asset_data.upload_dir}"
    file_path = "#{dir_path}/#{asset_data.name}"
    if File.exist?(file_path)
      send_file file_path, filename: asset_data.name, type: asset_data.content_type, disposition: 'inline'
    end
  end
  

  def destroy
    asset_data = AssetData.find(params[:id])
    if asset_data
      if asset_data.update_attributes({deleted_at: DateTime.now, deleted_by: @current_user.username})
        upload_root = UPLOAD_ROOT
        dir_path = "#{upload_root}/#{asset_data.upload_dir}"
        file_path = "#{dir_path}/#{asset_data.name}"
        if File.exist?(file_path)
          FileUtils.rm(file_path)
        end
        render json: {} #OK
      end
      render json: {} #Save error
      return
    end
    render json: {} #Find error
  end
end