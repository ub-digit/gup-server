class Rss::RssController < ApplicationController
  def index
    # parameter names departmentID and personID was used in scigloo
    param_department_id = params[:department_id] || params[:departmentID] || nil
    param_person_id = params[:person_id] || params[:personID] || nil

    publications = Publication.all
    if param_department_id
      publications = publications.department_id(param_department_id.split(";"))
    end
    if param_person_id
      publications = publications.person_id(param_person_id.split(";"))
    end
    publications = publications.non_deleted.published
    publications = publications.order(created_at: :desc)
    publications = publications.limit(20)

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.send(:"rss", "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/", "xmlns:atom" => "http://www.w3.org/2005/Atom") do
        xml.channel do
          xml.title APP_CONFIG['repository_name']
          xml.description APP_CONFIG['repository_name']
          xml.send(:"atom:link", "rel" => "self", "type" => "application/rss+xml", "href" => APP_CONFIG['public_base_url'])
          publications.each do |publication|
            xml.item do
              # RSS 2.0 elements
              xml.title publication.current_version.title
              xml.link APP_CONFIG['public_base_url'] + APP_CONFIG['publication_path'] + publication.id.to_s
              xml.description (publication.current_version.abstract? ? publication.current_version.abstract : publication.current_version.title)
              xml.pubDate publication.created_at.strftime("%FT%TZ")

              # Additional elements included in old scigloo RSS
              xml.guid APP_CONFIG['public_base_url'] + APP_CONFIG['publication_path'] + publication.id.to_s
              publication.current_version.get_authors_full_name.each do |author_full_name|
                xml.send(:"dc:creator", author_full_name)
              end
              publication.current_version.departments.uniq.each do |department|
                if !department.is_external? && department.name_sv
                  xml.send(:"dc:publisher", department.name_sv)
                end
              end
              xml.send(:"dc:type", publication.current_version.publication_type.code)
              xml.send(:"dc:date", publication.created_at.strftime("%FT%TZ"))
            end
          end
        end
      end
    end
    render xml: builder
  end
end
