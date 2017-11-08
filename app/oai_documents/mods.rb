class OaiDocuments
  class MODS
    def self.create_record publication
      utilities = OaiDocuments::Utilities.new
      xml = ::Builder::XmlMarkup.new
      xml.tag!("mods",
               'xmlns' => 'http://www.loc.gov/mods/v3',
               'xmlns:xlink' => 'http://www.w3.org/1999/xlink',
               'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
               'version' => '3.5',
               'xsi:schemaLocation' => %{http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd}) do

        # Get the publication type code in the local repository
        if publication.current_version.publication_type && publication.current_version.publication_type.code
          local_publication_type_code = publication.current_version.publication_type.code
        else
          # TODO: Handle this error
          local_publication_type_code = 'other'
        end
        # Get the content type (refvalue) in the local repository
        if publication.current_version.ref_value
          local_content_type = publication.current_version.ref_value
        else
          # TODO: Handle this error
          local_content_type = 'NOREF'
        end

        #### Record Info ####
        xml.tag!("recordInfo") do
          xml.tag!("recordContentSource", APP_CONFIG['oai_settings']['record_content_source'])
        end
        # Flag publication as non-validated if not bibliographic reviewed
        xml.tag!("note", "not verified at registration", 'type' => 'verificationStatus') unless !publication.current_version.biblreviewed_at


        #### Record Identifiers ###
        xml.tag!("identifier", utilities.get_uri_identifier(publication.id), 'type' => 'uri')
        # TODO, take care of publications_links


        #### Recource Identifiers ###
        # Only monograhps
        if utilities.is_monography?(local_publication_type_code)
          xml.tag!("identifier", publication.current_version.isbn, 'type' => 'isbn') unless !publication.current_version.isbn
        end
        publication.current_version.publication_identifiers.each do |identifier|
          if identifier.identifier_code && identifier.identifier_value
          code = utilities.get_identifier_code(identifier.identifier_code)
            if code
              xml.tag!("identifier", identifier.identifier_value, 'type' => code)
            end
          end
        end unless !publication.current_version.publication_identifiers


        #### Title and Subtitle ####
        xml.tag!("titleInfo") do
          xml.tag!("title", publication.current_version.title)
          xml.tag!("subTitle", publication.current_version.alt_title) unless !publication.current_version.alt_title
        end unless !publication.current_version.title


        #### Abstract ####
        xml.tag!("abstract", publication.current_version.abstract) unless !publication.current_version.abstract


        #### Subjects and Keywords ####
        # Subjects
        # Only deliver HSV_11 categories, mapped from HSV_LOCAL_12
        hsv_11_categories = Category.where(id: publication.current_version.categories.where(category_type: "HSV_LOCAL_12").map{|c| c.mapping_id})
        hsv_11_categories.each do |category|
          xml.tag!("subject", 'xmlns:xlink' => 'http://www.w3.org/1999/xlink', 'lang' => 'swe', 'authority' => 'uka.se', 'xlink:href' => category.svepid) do
            xml.tag!("topic", category.name_sv)
          end
          xml.tag!("subject", 'xmlns:xlink' => 'http://www.w3.org/1999/xlink', 'lang' => 'eng', 'authority' => 'uka.se', 'xlink:href' => category.svepid) do
            xml.tag!("topic", category.name_en)
          end
        end unless !hsv_11_categories
        # Keywords
        publication.current_version.keywords.split(",").each do |keyword|
          xml.tag!("subject") do
            xml.tag!("topic", keyword)
          end
        end unless !publication.current_version.keywords

        #### Language ####
        xml.tag!("language") do
          language_code = utilities.get_language_code publication.current_version.publanguage
          xml.tag!("languageTerm", language_code, 'type' => 'code', 'authority' => 'iso639-2b')
        end unless !publication.current_version.publanguage


        #### Resource Type ####
        #### Content Type ####
        publication_type_code = get_publication_type_code(local_publication_type_code)
        content_type_code = get_content_type_code(local_publication_type_code, local_content_type)
        output_code = get_output_code(local_publication_type_code)
        xml.tag!("genre", output_code, 'authority' => 'kb.se', 'type' => 'outputType')
        xml.tag!("genre", publication_type_code, 'authority' => 'svep', 'type' => 'publicationType')
        xml.tag!("genre", content_type_code, 'authority' => 'svep', 'type' => 'contentType')


        #### Publication Status ####
        if publication.epub_ahead_of_print
          xml.tag!("note", "Epub ahead of print/Online first",'type' => 'publicationStatus')
        else
          xml.tag!("note", "Published",'type' => 'publicationStatus')
        end


        #### Names and Affiliations ####
        #### Creator Count ####
        if publication.current_version.people2publications
          publication.current_version.people2publications.each do |p2p|
            person_identifier = p2p.person.get_identifier(source: 'xkonto') ? p2p.person.get_identifier(source: 'xkonto') : p2p.person.id
            xml.tag!("name", 'xmlns:xlink' => 'http://www.w3.org/1999/xlink', 'type' => 'personal', 'authority' => 'gu.se', 'xlink:href' => person_identifier) do
              xml.tag!("namePart", p2p.person.first_name, 'type' => 'given') unless !p2p.person.first_name
              xml.tag!("namePart", p2p.person.last_name, 'type' => 'family') unless !p2p.person.last_name
              xml.tag!("namePart", p2p.person.year_of_birth, 'type' => 'date') unless !p2p.person.year_of_birth
              xml.tag!("role") do
                # Role depends on publication type
                role = get_role(local_publication_type_code)
                xml.tag!("roleTerm", role, 'type' => 'code', 'authority' => 'marcrelator')
              end
              # Get orcid
              orcid = p2p.person.get_identifier(source: 'orcid')
              xml.tag!("description", orcid, 'xsi:type' => 'identifierDefinition', 'type' => 'orcid') unless !orcid
              # Affiliations for this creator
              affiliation_data = create_affiliation_data(p2p)
              if affiliation_data
                affiliation_data.each do |affiliation|
                  xml.tag!("affiliation", affiliation[:value], 'lang' => affiliation[:lang], 'authority' => affiliation[:authority], 'xsi:type' => 'mods:stringPlusLanguagePlusAuthority', 'valueURI' => affiliation[:valueURI])
                end
              end
            end
          end
          xml.tag!("note", publication.current_version.get_no_of_authors, 'type' => 'creatorCount')
        end

        # Organisations
        if publication.current_version.departments
          publication.current_version.departments.uniq.each do |department|
            next if department.is_external?
            xml.tag!("name", 'xmlns:xlink' => 'http://www.w3.org/1999/xlink', 'type' => 'corporate', 'lang' => 'swe', 'authority' => 'gu.se', 'xlink:href' => department.id.to_s) do
              xml.tag!("namePart", APP_CONFIG['university']['name_sv'])
              if department.faculty_id
                xml.tag!("namePart", Faculty.find_by_id(department.faculty_id).name_sv)
              end
              xml.tag!("namePart", department.name_sv)
            end
            xml.tag!("name", 'xmlns:xlink' => 'http://www.w3.org/1999/xlink', 'type' => 'corporate', 'lang' => 'eng', 'authority' => 'gu.se', 'xlink:href' => department.id.to_s) do
              xml.tag!("namePart", APP_CONFIG['university']['name_en'])
              if department.faculty_id
                xml.tag!("namePart", Faculty.find_by_id(department.faculty_id).name_en)
              end
              xml.tag!("namePart", department.name_en)
            end
          end
        end


        #### Contracts, Projects, Programmes and Strategic Initiatives ####
        # Optional, Not implemented


        #### Publication Date and Publisher ####
        if publication.current_version.pubyear || publication.current_version.publisher || publication.current_version.place
          xml.tag!("originInfo") do
            xml.tag!("dateIssued", publication.current_version.pubyear) unless !publication.current_version.pubyear
            xml.tag!("publisher", publication.current_version.publisher) unless !publication.current_version.publisher
            xml.tag!("place") do
              xml.tag!("placeTerm", publication.current_version.place)
            end unless !publication.current_version.place
          end
        end


        #### Source ####
        # Only for non-monographs
        if publication.current_version.sourcetitle && !utilities.is_monography?(local_publication_type_code)
          xml.tag!("relatedItem", 'type' => 'host') do
            xml.tag!("titleInfo") do
              xml.tag!("title", publication.current_version.sourcetitle)
            end
            xml.tag!("identifier", publication.current_version.issn, 'type' => 'issn') unless !publication.current_version.issn
            xml.tag!("identifier", publication.current_version.eissn, 'type' => 'issn') unless !publication.current_version.eissn
            # Should not exist with issn/eissn
            xml.tag!("identifier", publication.current_version.isbn, 'type' => 'isbn') unless !publication.current_version.isbn
            if publication.current_version.sourcevolume || publication.current_version.sourceissue || publication.current_version.sourcepages
              xml.tag!("part") do
                # Volume
                xml.tag!("detail", 'type' => 'volume') do
                  xml.tag!("number", publication.current_version.sourcevolume)
                end unless !publication.current_version.sourcevolume
                # Issue
                xml.tag!("detail", 'type' => 'issue') do
                  xml.tag!("number", publication.current_version.sourceissue)
                end unless !publication.current_version.sourceissue
                # Article number
                xml.tag!("detail", 'type' => 'artNo') do
                  xml.tag!("number", publication.current_version.article_number)
                end unless !publication.current_version.article_number
                # Pages
                start_end_pages = get_start_end_pages(publication.current_version.sourcepages)
                if start_end_pages
                  xml.tag!("extent") do
                    xml.tag!("start", start_end_pages[0])
                    xml.tag!("end", start_end_pages[1])
                  end
                else
                  xml.tag!("detail", 'type' => 'citation') do
                    xml.tag!("caption", publication.current_version.sourcepages)
                  end
                end unless !publication.current_version.sourcepages
              end
            end
          end
        end
        # Publication in series
        if publication.current_version.series && publication.current_version.series.first && publication.current_version.series.first.title
          publication.current_version.series2publications.each do |s2p|
            xml.tag!("relatedItem", 'type' => 'series') do
              xml.tag!("titleInfo") do
                xml.tag!("title", s2p.serie.title)
              end
              xml.tag!("identifier", s2p.serie.issn, 'type' => 'issn') unless !s2p.serie.issn
              # TODO: Better soluton
              xml.tag!("identifier", s2p.serie_part, 'type' => 'issue number') unless !s2p.serie_part
            end
          end
        end


        #### Location and Accessibility ####
        # TODO: Asset model should be extended to make possible to describe each file better, to decide if it's fulltext or not
        # TODO: This is a dummy, fix this when the new publication links model is ready
        # Fulltexts in the local repository
        publication.files.each do |file|
          if !file[:visible_after] || (file[:visible_after] && file[:visible_after] < Time.now)
            xml.tag!("location") do
              xml.tag!("url", utilities.get_uri_identifier(publication.id), 'note' => 'free', 'usage' => 'primary', 'displayLabel' => 'FULLTEXT')
            end
          else
            # TODO: Embagoed files?
          end
        end
        # External fulltexts
        if publication.current_version.url
          xml.tag!("location") do
            xml.tag!("url", publication.current_version.url, 'displayLabel' => 'FULLTEXT')
          end
        end


        #### Physical description ####
        # TODO: Asset model should be extended to make possible to describe each file better, to decide if it's fulltext or not
        if publication.has_viewable_file?
          xml.tag!("physicalDescription") do
            xml.tag!("form", "electronic", 'authority' => 'marcform')
          end
        end


        #### Resource Type ####
        # Depends on publication type
        resource_type = utilities.get_resource_type(local_publication_type_code)
        xml.tag!("typeOfResource", resource_type)


        #### Notes ####
        # Optional

      end
      xml.target!
    end


    def self.create_affiliation_data(p2p)
      if p2p.departments2people2publications
        result_sv = []
        result_en = []
        top_level_added = false
        p2p.departments2people2publications.each do |d2p2p|
          if d2p2p.department.faculty_id
            result_sv.push({value: APP_CONFIG['university']['name_sv'], lang: 'swe', authority: 'kb.se', valueURI: 'gu.se'}) unless top_level_added
            result_en.push({value: APP_CONFIG['university']['name_en'], lang: 'eng', authority: 'kb.se', valueURI: 'gu.se'}) unless top_level_added
            top_level_added = true unless top_level_added

            result_sv.push({value: d2p2p.department.name_sv, lang: 'swe', authority: 'gu.se', valueURI: 'gu.se/' + d2p2p.department.id.to_s})
            result_en.push({value: d2p2p.department.name_en, lang: 'eng', authority: 'gu.se', valueURI: 'gu.se/' + d2p2p.department.id.to_s})
          end
        end
        return result_sv + result_en
      else
        return nil
      end
    end

    def self.get_start_end_pages pages
      return nil if !pages
      pages_arr = pages.split("-")
      if pages_arr.length == 2
        return pages_arr
      end
      return nil
    end

    def self.get_publication_type_code publication_type
      code = output_mapping[publication_type.downcase][0]
      code.nil? ? 'ovr' : code
    end

    def self.get_content_type_code publication_type, content_type
      # Special fix for book chapter peer-reviewed
      if publication_type.eql?("publication_book-chapter") && content_type.eql?("ISREF")
        return 'ref'
      end
      code = output_mapping[publication_type.downcase][1]
      code.nil? ? 'vet' : code
    end

    def self.get_output_code publication_type
      code = output_mapping[publication_type.downcase][2]
      code.nil? ? 'publication/other' : code
    end

    def self.get_role publication_type
      role = role_mapping[publication_type.downcase]
      role.nil? ? 'aut' : role
    end

    def self.role_mapping
      {'conference_other' => 'aut',
       'conference_paper' => 'aut',
       'conference_poster' => 'aut',
       'publication_journal-article' => 'aut',
       'publication_magazine-article' => 'aut',
       'publication_edited-book' => 'edt',
       'publication_book' => 'aut',
       'publication_book-chapter' => 'aut',
       'intellectual-property_patent' => 'aut',
       'publication_report' => 'aut',
       'publication_doctoral-thesis' => 'aut',
       'publication_book-review' => 'aut',
       'publication_licentiate-thesis' => 'aut',
       'other' => 'aut',
       'publication_review-article' => 'aut',
       'artistic-work_scientific_and_development' => 'aut',
       'publication_textcritical-edition' => 'edt',
       'publication_textbook' => 'aut',
       'artistic-work_original-creative-work' => 'aut',
       'publication_editorial-letter' => 'aut',
       'publication_report-chapter' => 'aut',
       'publication_newspaper-article' => 'aut',
       'publication_encyclopedia-entry' => 'aut',
       'publication_journal-issue' => 'edt',
       'conference_proceeding' => 'edt',
       'publication_working-paper' => 'aut'}
    end

    def self.output_mapping
      {'conference_other' => ['kon', 'vet', 'conference/other'],
       'conference_paper' => ['kon', 'ref', 'conference/paper'],
       'conference_poster' => ['kon', 'vet', 'conference/poster'],
       'publication_journal-article' => ['art', 'ref', 'publication/journal-article'],
       'publication_magazine-article' => ['art', 'vet', 'publication/magazine-article'],
       'publication_edited-book' => ['sam', 'vet', 'publication/edited-book'],
       'publication_book' => ['bok', 'vet', 'publication/book'],
       'publication_book-chapter' => ['kap', 'vet', 'publication/book-chapter'],
       'intellectual-property_patent' => ['pat', 'vet', 'intellectual-property/patent'],
       'publication_report' => ['rap', 'vet', 'publication/report'],
       'publication_doctoral-thesis' => ['dok', 'vet', 'publication/doctoral-thesis'],
       'publication_book-review' => ['rec', 'vet', 'publication/book-review'],
       'publication_licentiate-thesis' => ['lic', 'vet', 'publication/licentiate-thesis'],
       'other' => ['ovr', 'vet', 'publication/other'],
       'publication_review-article' => ['for', 'ref', 'publication/review-article'],
       'artistic-work_scientific_and_development' => ['kfu', 'vet', 'artistic-work'], # ?????
       'publication_textcritical-edition' => ['sam', 'vet', 'publication/edited-book'],
       'publication_textbook' => ['bok', 'vet', 'publication/book'],
       'artistic-work_original-creative-work' => ['kfu', 'vet', 'artistic-work/original-creative-work'],
       'publication_editorial-letter' => ['art', 'vet', 'publication/editorial-letter'],
       'publication_report-chapter' => ['kap', 'vet', 'publication/report-chapter'],
       'publication_newspaper-article' => ['art', 'pop', 'publication/newspaper-article'],
       'publication_encyclopedia-entry' => ['kap', 'vet', 'publication/encyclopedia-entry'],
       'publication_journal-issue' => ['ovr', 'vet', 'publication/journal-issue'],
       'conference_proceeding' => ['pro', 'vet', 'conference/proceeding'],
       'publication_working-paper' => ['ovr', 'vet', 'publication/working-paper']}
    end
  end
end
