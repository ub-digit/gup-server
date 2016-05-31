require 'rails_helper'

RSpec.describe Language, type: :model do

  # METHODS
  describe "all" do
    it "should return all language objects" do
      count = APP_CONFIG['languages'].count

      expect(Language.all.count).to eq count
    end
  end

  describe "find_by_code" do
    before :each do
      I18n.locale = :en
    end
    context "for nil code" do
      it "should return nil" do
        result = Language.find_by_code(nil)

        expect(result).to be nil
      end
    end

    context "for an existing code" do
      it "should return an object for given code" do
        result = Language.find_by_code('en')

        expect(result[:label]).to eq "English"
        expect(result[:value]).to eq 'en'
      end
    end

    context "for a non existing code" do
      it "should return nil" do
        result = Language.find_by_code('nolang')

        expect(result).to be nil
      end
    end
  end

  describe "all_codes" do
    it "should return an array of all codes" do
      result = Language.all_codes

      expect(result).to be_an Array
      expect(result).to_not be_empty
    end
  end

  describe "language_code_map" do
    context "for a configured language_code" do
      it "should return the mapped language code" do
        result = Language.language_code_map('eng')

        expect(result).to eq "en"
      end
    end
    context "for an empty string" do
      it "should return english code" do
        result = Language.language_code_map('')

        expect(result).to eq 'en'
      end
    end
    context "for a non configured language_code" do
      it "should return the given language" do
        result = Language.language_code_map('nolang')

        expect(result).to eq 'nolang'
      end
    end
  end
end
