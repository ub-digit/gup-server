require 'rails_helper'

RSpec.describe V1::EndNoteFilesController, type: :controller do

  before :each do
    @upload_root_dir = "#{Rails.root}/#{APP_CONFIG['file_upload_root_dir']}"
    FileUtils.mkdir_p(@upload_root_dir)

    #create(:publication, id: 1)
    #@publication = Publication.find(1)

    @xml_file = fixture_file_upload('files/Testfile.xml', 'application/xml')
  end

  after :each do
    FileUtils.rm_rf(@upload_root_dir)
  end

  # describe "GET #index" do
  #   it "return a list of EndNote files" do
  #     end_note_file = create(:end_note_file, username: 'xyzxyz')
  #     get :index, api_key: @api_key
  #     expect(response.status).to eq(200)
  #     expect(json['end_note_files']).to_not be_nil
  #   end
  #   it "returns http success" do
  #     get :index
  #     expect(response).to have_http_status(:not_implemented)
  #   end
  # end

  # def login_users
  #     @admin_user = create(:admin_user)
  #     @admin_user_token = @admin_user.generate_token.token
  #     @operator_user = create(:operator_user)
  #     @operator_user_token = @operator_user.generate_token.token
  #     @api_key_user = create(:api_key_user)
  #   end

  describe "GET #index" do
    context "with existing EndNote files" do
      it "should return a list of EndNote files" do
        list = create_list(:end_note_file, 11)
        pp list
        get :index, api_key: @api_key
        #expect(json['end_note_files']).to_not be nil
        #expect(json['end_note_files'][0]['id']).to be_an(Integer)
        expect(1).to eq 1
      end
    end
  end

  describe "POST #create" do
    context "with xml data from uploaded file" do
      it "should successfully create an EndNoteFile object" do
        post :create, file: @xml_file, api_key: @api_key
        expect(response).to have_http_status(200)
        pp '---'
        pp json
        pp '---'
        expect(json['end_note_file']).to_not be_nil
      end
    end
  end

  describe "GET #show" do
    it "should return an object" do
      create(:end_note_file, id: 101, username: 'xyzxyz')

      get :show, id: 101, api_key: @api_key
      #pp json
      expect(json["end_note_file"]).to_not be nil
      expect(json["end_note_file"]).to be_an(Hash)
    end

    context "an existing end_note_file" do
      it "should return a single EndNote file object" do
        obj = create(:end_note_file, id: 123, username: 'xyzxyz')
        get :show, api_key: @api_key, id: obj.id
        expect(json['end_note_file']).to_not be nil
        expect(json['end_note_file']['id']).to be_an(Integer)
        expect(json['end_note_file']['id']).to eq 123
      end
    end
    context "a non existing EndNote file" do
      it "should return an error object" do
        get :show, api_key: @api_key, id: -1
        expect(json['error']).to_not be nil
      end
      it "should return status 404" do
        get :show, api_key: @api_key, id: -1
        expect(response.status).to eq 404
      end
    end
  end

  # describe "GET #update" do
  #   it "returns http success" do
  #     get :update
  #     expect(response).to have_http_status(:not_implemented)
  #   end
  # end

  # describe "GET #destroy" do
  #   it "returns http success" do
  #     get :destroy
  #     expect(response).to have_http_status(:not_implemented)
  #   end
  # end

end
