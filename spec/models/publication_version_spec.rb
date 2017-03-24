require 'rails_helper'

RSpec.describe PublicationVersion, type: :model do

  describe "relations" do
    it {should belong_to(:publication)}
    it {should belong_to(:publication_type)}
    it {should have_many(:publication_identifiers)}
    it {should have_many(:people2publications)}
    it {should have_many(:authors)}
    it {should have_many(:projects2publications)}
    it {should have_many(:projects)}
    it {should have_many(:series2publications)}
    it {should have_many(:categories2publications)}
    it {should have_many(:categories)}
  end

  # VALIDATIONS
  describe "pubyear for a published publication" do
    context "for a published publication" do
      subject{build(:published_publication).current_version}
      it {should allow_value(2000).for(:pubyear)}
      it {should_not allow_value(201).for(:pubyear)}
      it {should_not allow_value(-1).for(:pubyear)}
      it {should_not allow_value("aa").for(:pubyear)}
      it {should validate_numericality_of(:pubyear)}
    end

    context "for a draft publication" do
      subject{build(:draft_publication).current_version}
      it {should allow_value(2000).for(:pubyear)}
      it {should allow_value(201).for(:pubyear)}
      it {should allow_value(-1).for(:pubyear)}
      it {should allow_value("aa").for(:pubyear)}
    end
  end

  describe "publication_type" do
    context "for a draft_publication" do
      subject{build(:draft_publication).current_version}
      it {should_not validate_presence_of(:publication_type)}
    end

    context "for a published_publication" do
      subject{build(:published_publication).current_version}
      it {should validate_presence_of(:publication_type)}
    end
  end

  # METHODS
  describe "as_json" do
    it "should return a json representation" do
      pv = create(:published_publication).current_version
      publication = pv.publication
      json = pv.as_json

      expect(json[:version_id]).to_not be nil
      expect(json[:version_id]).to eq pv.id
      expect(json).to have_key 'category_hsv_local'
      expect(json).to have_key 'publication_type_label'
      expect(json['ref_value_label']).to_not be nil

    end
  end

  describe "is_published?" do
    context "for a published publication" do
      it "should return true" do
        pv = build(:published_publication).current_version

        expect(pv.is_published?).to be true
      end
    end

    context "for a draft publication" do
      it "should return false" do
        pv = build(:draft_publication).current_version

        expect(pv.is_published?).to be false
      end
    end
  end


  describe "get_authors_full_name" do
    it "should return a list of full name for all authors" do
      pv = create(:publication_version)
      p1 = create(:person, first_name: "First first", last_name: "First last")
      p2 = create(:person, first_name: "Second first", last_name: "Second last")
      p3 = create(:person, first_name: nil, last_name: "Third last")
      p2p1 = create(:people2publication, publication_version: pv, person: p1)
      p2p2 = create(:people2publication, publication_version: pv, person: p2)
      p2p3 = create(:people2publication, publication_version: pv, person: p3)

      expect(pv.get_authors_full_name).to eq ["First first First last", "Second first Second last", "Third last"]
    end
  end

  describe "get_authors_identifier" do
    describe "when identifier is xkonto" do
      it "should return a list of xkonto for the authors who have an xkonto registered" do
        pv = create(:publication_version)

        p1 = create(:person)
        p2 = create(:person)
        p3 = create(:person)

        i1 = create(:xkonto_identifier, value: "xaaaaa", person: p1)
        i2 = create(:xkonto_identifier, value: "xbbbbb", person: p2)
        i3 = create(:orcid_identifier, value: "0000-0000-0000-1111", person: p2)

        p2p1 = create(:people2publication, publication_version: pv, person: p1)
        p2p2 = create(:people2publication, publication_version: pv, person: p2)
        p2p3 = create(:people2publication, publication_version: pv, person: p3)

        expect(pv.get_authors_identifier(source: "xkonto")).to eq ["xaaaaa", "xbbbbb"]
      end
    end

    describe "when identifier is orcid" do
      it "should return a list of xkonto for the authors who have an orcid registered" do
        pv = create(:publication_version)

        p1 = create(:person)
        p2 = create(:person)
        p3 = create(:person)

        i1 = create(:orcid_identifier, value: "0000-0000-0000-1111", person: p1)
        i2 = create(:orcid_identifier, value: "0000-0000-0000-2222", person: p2)
        i3 = create(:xkonto_identifier, value: "xaaaaa", person: p2)

        p2p1 = create(:people2publication, publication_version: pv, person: p1)
        p2p2 = create(:people2publication, publication_version: pv, person: p2)
        p2p3 = create(:people2publication, publication_version: pv, person: p3)

        expect(pv.get_authors_identifier(source: "orcid")).to eq ["0000-0000-0000-1111", "0000-0000-0000-2222"]
      end
    end
  end

  describe "get_no_of_authors" do
    it "should return correct number of authors" do
        pv = create(:publication_version)

        p1 = create(:person)
        p2 = create(:person)

        i1 = create(:xkonto_identifier, value: "xaaaaa")
        i2 = create(:xkonto_identifier, value: "xbbbbb")

        p2p1 = create(:people2publication, publication_version: pv, person: p1)
        p2p2 = create(:people2publication, publication_version: pv, person: p2)

        expect(pv.get_no_of_authors).to be 2
    end
  end

  describe "category_svep_id" do
    context "for a given category" do
      it "should return array containing svepid" do
        pv = create(:publication_version)
        category = create(:category, svepid: "1234")
        c2p = create(:categories2publication, publication_version: pv, category: category)

        expect(pv.category_svep_ids).to be_an Array
        expect(pv.category_svep_ids).to include 1234
      end
    end
  end

  describe "review_diff" do
    context "against a differing publication_type" do
      it "should return publication type in hash" do
        pv = build(:publication_version, publication_type: build(:publication_type, code: 'type1'))
        pv2 = build(:publication_version, publication_type: build(:publication_type, code: 'type2'))

        result = pv.review_diff(pv2)

        expect(result[:publication_type]).to_not be nil
        expect(result[:publication_type][:from]).to eq I18n.t('publication_types.type2.label')
        expect(result[:publication_type][:to]).to eq I18n.t('publication_types.type1.label')
      end
    end

    context "against a differing list of categories" do
      it "should include list of categories for both versions" do
        category1 = create(:category, svepid: 123)
        category2 = create(:category, svepid: 321)
        pv1 = create(:publication_version)
        pv2 = create(:publication_version)
        c2p1 = create(:categories2publication, publication_version: pv1, category: category1)
        c2p2 = create(:categories2publication, publication_version: pv1, category: category2)
        c2p3 = create(:categories2publication, publication_version: pv2, category: category2)

        result = pv1.review_diff(pv2)

        expect(result[:category_hsv_local]).to_not be nil
        expect(result[:category_hsv_local][:from].size).to eq 1
        expect(result[:category_hsv_local][:to].size).to eq 2
      end
    end

    context "against a differing ref_value" do
      it "should show the value before and after" do
        pv1 = build(:publication_version, ref_value: "ISREF")
        pv2 = build(:publication_version, ref_value: "NOTREF")

        result = pv1.review_diff(pv2)

        expect(result[:ref_value]).to_not be nil
        expect(result[:ref_value][:from]).to eq I18n.t('ref_values.NOTREF')
        expect(result[:ref_value][:to]).to eq I18n.t('ref_values.ISREF')
      end
    end
  end

  describe "publanguage_label" do
    context "for an existing language" do
      it "should return the label" do
        pv = build(:publication_version, publanguage: 'en')

        result = pv.send(:publanguage_label)

        expect(result).to eq "Engelska"
      end
    end

    context "for a non existing language" do
      it "should return the language code" do
        pv = build(:publication_version, publanguage: 'xtr')

        result = pv.send(:publanguage_label)

        expect(result).to eq "xtr"
      end
    end
  end

end
