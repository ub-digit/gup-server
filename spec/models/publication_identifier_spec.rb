require 'rails_helper'

RSpec.describe PublicationIdentifier, type: :model do

  describe "publication_version_id" do
    it {should validate_presence_of(:publication_version_id)}
  end

  describe "identifier_code" do
    it {should validate_presence_of(:identifier_code)}
    it {should_not allow_value('WRONG').for(:identifier_code)}
    it {should allow_value('pubmed').for(:identifier_code)}
  end

  describe "identifier_value" do
    it {should validate_presence_of(:identifier_value)}
  end
end
