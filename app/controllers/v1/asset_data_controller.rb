class V1::AssetDataController < V1::V1Controller

  def create
    publication = Publication.find(params[:publication_id])
    if publication
      infile = params[:file]
      name = infile.original_filename
      content_type = infile.content_type
      checksum = Digest::MD5.hexdigest(name + Time.now.to_s + rand.to_s)
      asset_data = publication.asset_data.build(name: name, content_type: content_type, checksum: checksum, accepted: false, created_by: @current_user.username)
      upload_dir = get_file_path(checksum)
      extension = Pathname.new(name).extname
      FileUtils.mkdir_p(upload_dir)
      File.open("#{upload_dir}/#{checksum}#{extension}", "wb") do |file|
        file.write(infile.read)
      end
      if publication.save
        render json: {asset_data: asset_data} #OK
        return
      end
    end
    render json: {} #Find error
  end
  
  def show
    asset_data = AssetData.find(params[:id])
    if asset_data
      dir_path = get_file_path(asset_data.checksum)
      extension = Pathname.new(asset_data.name).extname
      file_path = "#{dir_path}/#{asset_data.checksum}#{extension}"
      if File.exist?(file_path)
        send_file file_path, filename: asset_data.name, type: asset_data.content_type, disposition: 'inline'
        return 
      end
    end
    render json: {} #Find error
  end

  def update
    asset_data = AssetData.find(params[:id])
    if asset_data
      if asset_data.update_attributes(params.require(:asset_data).permit(:accepted, :visible_after))
        render json: {} #OK
        return 
      end
    else
      render json: {} #Save error
      return 
    end
    render json: {} #Find error
  end


  def destroy
    asset_data = AssetData.find(params[:id])
    if asset_data
      if asset_data.update_attributes({deleted_at: DateTime.now, deleted_by: @current_user.username})
        dir_path = get_file_path(asset_data.checksum)
        file_path = "#{dir_path}/#{asset_data.checksum}"
        if File.exist?(file_path)
          FileUtils.rm(file_path)
        end
        render json: {} #OK
        return
      end
      render json: {} #Save error
      return
    end
    render json: {} #Find error
  end

private
  def get_file_path checksum
    APP_CONFIG['file_upload_root_dir'] + "/" + checksum[0..1] + "/" + checksum[2..3]
  end
end
