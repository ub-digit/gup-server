require 'rails_helper'

RSpec.describe PublicationType, :type => :model do

  before :each do
    APP_CONFIG['publication_types'] = YAML.load_file("#{Rails.root}/config/publication_types_test.yml")['publication_types']
  end

  describe "find_by_code" do
    context "for a valid code" do
      it "should return a PublicationType object" do
        pt = PublicationType.find_by_code("journal-articles")

        expect(pt).to be_a(PublicationType)
      end
    end
    context "for an invalid code" do
      it "should return nil" do
        pt = PublicationType.find_by_code("non_exisiting_pt")

        expect(pt).to be nil
      end
    end
  end

  describe "all" do
    context "for list of PublicationType" do
      it "should return all PublicationTypes" do
        pts = PublicationType.all

        expect(pts.empty?).to be_falsey
        expect(pts.first).to be_a(PublicationType)
      end
    end
    context "for empty list of publicationTypes" do
      it "should return empty array" do
        APP_CONFIG['publication_types'] = []

        pts = PublicationType.all

        expect(pts.empty?).to be_truthy
        expect(pts).to be_an(Array)
      end
    end
  end

  describe "generate_combined_fields" do
    context "with templates" do
      it "should return complete list of fields" do
        pt = PublicationType.find_by_code("journal-articles")

        fields = pt.generate_combined_fields

        expect(fields.count).to eq 6
      end
    end

    context "with templates and inclusive fields" do
      it "should return a complete list of fields" do
        pt = PublicationType.find_by_code("magazine-articles")

        fields = pt.generate_combined_fields

        expect(fields.count).to eq 7
      end
    end

    context "with templates and excluding fields" do
      it "should return a complete list of fields without excluded fields" do
        pt = PublicationType.find_by_code("donaldduck-articles")

        fields = pt.generate_combined_fields
        abstract_field = fields.find{|f| f['name'] == 'abstract' }

        expect(fields.count).to eq 5
        expect(abstract_field).to be nil
      end
    end
  end

  describe "get_all_fields" do
    context "for full config" do
      it "should return all fields mentioned in config" do
        fields = PublicationType.get_all_fields

        expect(fields.count).to eq 6
      end
    end
  end

  describe "active_fields" do
    context "for valid publication type" do
      it "should return array of field names" do
        pt = PublicationType.find_by_code("journal-articles")
        field_names = pt.active_fields

        expect(field_names.count).to eq 6
        expect(field_names).to be_an(Array)
        expect(field_names.include?('abstract')).to be_truthy
        expect(field_names.include?('mag-nr')).to be_falsey
      end
    end
  end

end
