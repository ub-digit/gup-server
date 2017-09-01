namespace :publication do
  desc "Creates static publication lists"
  task :create_lists => :environment do

    FileUtils.mkdir_p('public/static/lists/')
    Dir.glob('public/static/lists/*.html') do |file|
      FileUtils.rm(file)
    end
    filenames = []
    Publication.published.non_deleted.each do |publication|
      filename = "public/static/lists/publication_list_#{publication.updated_at.year}.html"
      if !File.file?(filename)
        filenames << filename
        File.open(filename, "w") do |f|
          f.write("<!DOCTYPE html>\n")
          f.write("<html>\n")
          f.write(" <body>\n")
        end
      end
      File.open(filename, "a") do |f|
        url = "#{APP_CONFIG['public_base_url']}#{APP_CONFIG['publication_path']}#{publication.id}"
        f.write("  <a href=\"#{url}\">#{url}</a><br/>\n")
      end
    end
    Dir.glob('public/static/lists/*.html') do |file|
      File.open(file, "a") do |f|
        f.write(" </body>\n")
        f.write("</html>\n")
      end
    end

    File.open("public/static/lists/publication_lists.html", "w") do |f|
      f.write("<!DOCTYPE html>\n")
      f.write("<html>\n")
      f.write(" <body>\n")
      filenames.sort.each do |filename|
        filename_path_excluded = filename.split('/')[-1]
        f.write("  <a href=\"/static/lists/#{filename_path_excluded}\">#{filename_path_excluded}</a><br/>\n")
      end
      f.write(" </body>\n")
      f.write("</html>\n")
    end
  end
end
