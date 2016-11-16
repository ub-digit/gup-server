FactoryGirl.define do

  sequence :endnote_record_id do |n|
    n
  end

  sequence :endnote_record_checksum do |n|
    n
  end

#attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :issn, :sourcetitle, :sourcevolume, :sourceissue, :sourcepages, :publisher, :place, :extent, :author, :isbn, :patent_applicant, :patent_date, :patent_number, :links, :extid, :doi_url, :xml

  factory :endnote_record do
    id {generate :endnote_record_id}
    checksum {generate :endnote_record_checksum}
    username 'test_key_user'

    trait :article do
      title "the title"
      alt_title "the alt_title"
      abstract "the abstract"
      keywords "the keywords"
      pubyear "1999"
      language "sv"
      issn "1234-1234"
      sourcetitle "the sourcetitle"
      sourcevolume "1"
      sourceissue "1"
      sourcepages "10-16"
      publisher "the publisher"
      place "the place"
      #extent ""
      doi '11.1111/111-1-1111-1111-1'
      doi_url 'https://doi.org/11.1111/111-1-1111-1111-1'
      xml "<xml></xml>"
    end

    factory :endnote_article_record, traits: [:article]
  end
end
