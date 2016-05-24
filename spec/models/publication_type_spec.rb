require 'rails_helper'

RSpec.describe PublicationType, :type => :model do

  describe "code" do
    subject{build(:publication_type)}
    it {should validate_presence_of(:code)}
    it {should validate_uniqueness_of :code}
  end
  describe "ref_options" do
    it {should validate_presence_of(:ref_options)}
    it {should validate_inclusion_of(:ref_options).in_array(['ISREF', 'NOTREF', 'BOTH', 'NONE'])}
  end

end
