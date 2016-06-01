require 'rails_helper'

RSpec.describe DataSource, type: :model do
  describe "all" do
    it "should return datasources when available" do
      expect(DataSource.all).to be_kind_of(Array)
    end
    
    it "should return empty array when datasources are not available" do
      save_ds = APP_CONFIG['data_sources']
      APP_CONFIG['data_sources'] = nil
      
      ds = DataSource.all
      expect(ds).to be_kind_of(Array)
      expect(ds).to be_empty
      
      APP_CONFIG['data_sources'] = save_ds
    end
  end
end
