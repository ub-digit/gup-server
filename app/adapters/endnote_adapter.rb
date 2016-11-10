class EndnoteAdapter
  attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :issn, :sourcetitle, :sourcevolume, :sourceissue, :sourcepages, :publisher, :place, :extent, :author, :isbn, :patent_applicant, :patent_date, :patent_number, :links, :extid, :doi_url, :xml

  include ActiveModel::Serialization

  DOI_URL_PREFIX = 'http://dx.doi.org/'

  PERIODICAL_TYPES = [5, 17, 19, 23, 47]
  MONOGRAPH_TYPES = [6, 25, 27, 28, 32]
  PATENT_TYPES = [25]
  #EDITED_BOOK_TYPES = [28]

  def initialize hash
    #pp '-*- EndnoteAdapter.initialize -*-'
    @xml = hash[:xml]

    #pp "-*- EndnoteAdapter.initialize -*- Class: #{xml.class}"
    parse_xml
  end

  def self.parse xml
    #pp '-*- EndnoteAdapter.parse_xml -*-'
    endnote_record = EndnoteRecord.new
    # This will only work with endnote 8
    #@xml = force_utf8(@xml)
    #pp 'EndnoteAdapter.parse: hej, created endnote_record object'
    # create checksum
    # store username

    ref_type = xml.search('./ref-type').text.to_i

    endnote_record.title = xml.search('./titles/title/style').text
    endnote_record.alt_title = xml.search('./titles/secondary_title/style').text
    endnote_record.pubyear = xml.search('./dates/year/style').text
    endnote_record.abstract = xml.search('./abstract/style').text
    endnote_record.language = xml.search('./language/style').text

    endnote_record.keywords = xml.search('./keywords/keyword/style').map do |keyword|
      [keyword.text]
    end.join(", ")

    #@author = xml.search('./contributors/authors/author/style').map do |author|
    #  [author.text]
    #end.join("; ")

    endnote_record.publisher = xml.search('./publisher/style').text
    endnote_record.place = xml.search('./pub-location/style').text

    if PATENT_TYPES.include?(ref_type)
      endnote_record.patent_applicant = xml.search('./publisher/style').text
      endnote_record.patent_date = xml.search('./date/style').text
      endnote_record.patent_number = xml.search('./isbn/style').text
    end

    if MONOGRAPH_TYPES.include?(ref_type)
      endnote_record.isbn = xml.search('./isbn/style').text
    else
      endnote_record.issn = xml.search('./isbn/style').text
    end

    if MONOGRAPH_TYPES.include?(ref_type)
      endnote_record.extent =  xml.search('./pages/style').text
    end

    if PERIODICAL_TYPES.include?(ref_type)
      endnote_record.sourcetitle = xml.search('./periodical/full-title/style').text
      endnote_record.sourcevolume = xml.search('./volume/style').text
      endnote_record.sourceissue = xml.search('./number/style').text
      endnote_record.sourcepages = xml.search('./pages/style').text
    end

    if xml.search('./electronic-resource-num/style').text.present?
      endnote_record.doi_url = DOI_URL_PREFIX + xml.search('./electronic-resource-num/style').text
    end

    endnote_record.extid = xml.search('./accession-num/style').text
    return endnote_record

  end

  #def self.parse xml
  #  #pp '-*- EndnoteAdapter.parse -*-'
  #  self.new xml: xml
  #end

private
  def force_utf8(str)
    #pp '-*- EndnoteAdapter.force_utf8 -*-'
    if !str.force_encoding("UTF-8").valid_encoding?
      str = str.force_encoding("ISO-8859-1").encode("UTF-8")
    end
    return str
  end

  # Copied from Publications controller, not used at all at the moment, kept for future reference
  def handle_file_import raw_xml
    #pp '-*- EndnoteAdapter.handle_file_import -*-'
    if raw_xml.blank?
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.no_data_in_file"}")
      render_json
      return
    end

    xml = Nokogiri::XML(raw_xml)
    if !xml.errors.empty?
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.invalid_file"}", xml.errors)
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
      error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.unsupported_endnote_version"}")
      render_json
      return
    end

    record_count = 0
    record_total = 0
    return_pub = {}

    xml.search('//xml/records/record').each do |record|
      record_total += 1
      params[:publication] = {}
      endnote = Endnote.parse(record)
      if endnote
        params[:publication].merge!(endnote.as_json)
      else
        params[:publication][:title] = "[Title not found]"
      end

      create_basic_data
      pub = Publication.new(permitted_params(params))
      if pub.save
        record_count += 1
        if record_count == 1
          return_pub = pub
        end
      else
        error_msg(ErrorCodes::VALIDATION_ERROR, "#{I18n.t "publications.errors.update_error"}", pub.errors)
        render_json
        return
      end
    end
    @response[:publication] = return_pub
    @response[:meta] = {result: {count: record_count, total: record_total}}
    render_json(201)
  end

end
