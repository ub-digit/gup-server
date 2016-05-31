require 'rails_helper'

RSpec.describe Category, type: :model do
 # RELATIONS
  describe "relations" do
    it {should have_many(:children)}
    it {should belong_to(:parent)}
  end

  # METHODS
  describe "name" do
    context "for locale sv" do
      before :each do
        I18n.locale = :sv
      end
      it "should return name in swedish" do
        category = build(:category, name_en: "English name", name_sv: "Svenskt namn")

        expect(category.name).to eq "Svenskt namn"
      end
    end
    context "for locale :en" do
      before :each do
        I18n.locale = :en
      end
      it "should return name in english" do
        category = build(:category, name_en: "English name", name_sv: "Svenskt namn")

        expect(category.name).to eq "English name"
      end
    end
    context "for locale :zh (which is not defined for category)" do
      before :each do
        I18n.available_locales = (I18n.available_locales + [:zh]).uniq
        I18n.locale = :zh
      end
      after :each do
        I18n.available_locales = (I18n.available_locales - [:zh]).uniq
      end
      it "should return name in english" do
        category = build(:category, name_en: "English name", name_sv: "Svenskt namn")

        expect(category.name).to eq "English name"
      end
    end
  end

  describe "name_path" do
    context "for locale :en" do
      before :each do
        I18n.locale = :en
      end
      context "where name_path exists" do
        it "should return a concatenation of name_path and name in english" do
          category = build(:category, name_en: "English name", en_name_path: "Parent|Parent2")

          expect(category.name_path).to eq "Parent|Parent2|English name"
        end
      end
      context "where name_path does not exist" do
        it "should return name in english" do
          category = build(:category, name_en: "English name")

          expect(category.name_path).to eq "English name"
        end
      end
    end
    context "for locale :sv" do
      before :each do
        I18n.locale = :sv
      end
      context "where name_path exists" do
        it "should return a concatenation of name_path and name in swedish" do
          category = build(:category, name_sv: "Svenskt namn", sv_name_path: "Foralder|Foralder2")

          expect(category.name_path).to eq "Foralder|Foralder2|Svenskt namn"
        end
      end
      context "where name_path does not exist" do
        it "should return name in swedish" do
          category = build(:category, name_sv: "Svenskt namn")

          expect(category.name_path).to eq "Svenskt namn"
        end
      end
    end
    context "for locale :zh (which is not configured for category)" do
      before :each do
        I18n.available_locales = (I18n.available_locales + [:zh]).uniq
        I18n.locale = :zh
      end
      after :each do
        I18n.available_locales = I18n.available_locales - [:zh]
      end
      context "where name_path exists" do
        it "should return a concatenation of name_path and name in english" do
          category = build(:category, name_en: "English name", en_name_path: "Parent|Parent2", name_sv: "Svenskt namn", sv_name_path: "Foralder|Foralder2")

          expect(category.name_path).to eq "Parent|Parent2|English name"
        end
      end
      context "where name_path does not exist" do
        it "should return name in english" do
          category = build(:category, name_en: "English name", name_sv: "Svenskt namn", sv_name_path: "Foralder|Foralder2")

          expect(category.name_path).to eq "English name"
        end
      end
    end
  end

  describe "as_json" do
    context "with option 'light' set" do
      it "should contain certain information" do
        I18n.locale = :en
        category = build(:category, id: 123, svepid: 234, name_en: "English name", en_name_path: "Parent|Parent2", node_type: "Type1")

        json = category.as_json({light: true})

        expect(json[:id]).to eq 123
        expect(json[:svepid]).to eq 234
        expect(json[:name]).to eq "English name"
        expect(json[:name_path]).to eq "Parent|Parent2|English name"
        expect(json[:node_type]).to eq "Type1"
        expect(json[:children]).to eq []
        expect(json['name_en']).to be nil
      end
    end

    context "with no option set" do
      it "should contain all fields" do
        I18n.locale = :en
        category = build(:category, id: 123, svepid: 234, name_en: "English name", en_name_path: "Parent|Parent2", node_type: "Type1")

        json = category.as_json

        expect(json[:id]).to eq 123
        expect(json[:name_path]).to eq "Parent|Parent2|English name"
        expect(json['name_en']).to eq "English name"
      end
    end
  end

  describe "find_by_query" do
    context "for a given query" do
      it "should return a relation subset of categories" do
        create(:category, name_en: "english name")
        create(:category, name_en: "english")
        create(:category, name_en: "other")

        result = Category.find_by_query(query: 'english')

        expect(result.count).to eq 2
      end
    end
  end

  describe "find_by_ids" do
    context "for a list of svepids" do
      it "should return categories matching array" do
        create(:category, svepid: 123)
        create(:category, svepid: 124)
        create(:category, svepid: 125)

        result = Category.find_by_ids([123,124])

        expect(result.count).to eq 2
      end
    end
  end


end
