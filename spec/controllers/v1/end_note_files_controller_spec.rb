require 'rails_helper'

RSpec.describe V1::EndNoteFilesController, type: :controller do

  before :all do
    @user = User.create(username: "xanother", first_name: "Another", last_name: "Usersson", role: "USER")
  end

  before :each do
    @upload_root_dir = "#{Rails.root}/#{APP_CONFIG['file_upload_root_dir']}"
    FileUtils.mkdir_p(@upload_root_dir)

    @xml_file = fixture_file_upload('files/Testfile.xml', 'application/xml')
  end

  after :each do
    FileUtils.rm_rf(@upload_root_dir)
  end

  describe "GET #index" do
    context "with existing EndNote files for current user" do
      it "should return a list of EndNote files" do
        list = create_list(:end_note_file, 11)
        get :index, username: @user.username, api_key: @api_key
        expect(json['end_note_files']).to_not be nil
        expect(json['end_note_files'][0]['id']).to be_an(Integer)
        expect(json['end_note_files'].count).to eq 11
      end
    end
    context "when files exist for current user and other users" do
      it "should return a list of EndNote files for current user only" do
        file1 = create(:end_note_file, id: '1', username: @user.username)
        file2 = create(:end_note_file, id: '2', username: @user.username)
        file3 = create(:end_note_file, id: '3', username: @user.username)
        file4 = create(:end_note_file, id: '4', username: @user.username)
        file5 = create(:end_note_file, id: '5', username: 'test_key_user')
        file6 = create(:end_note_file, id: '6', username: 'test_key_user')
        file7 = create(:end_note_file, id: '7', username: 'test_key_user')
        file8 = create(:end_note_file, id: '8', username: 'test_key_user')

        get :index, username: @user.username, api_key: @api_key
        expect(json['end_note_files']).to_not be nil
        expect(json['end_note_files'].count).to eq 4
      end
    end
  end

  describe "POST #create" do
    context "with xml data from uploaded file" do
      it "should successfully create an EndNoteFile object" do
        post :create, file: @xml_file, api_key: @api_key
        expect(response).to have_http_status(200)
        expect(json['end_note_file']).to_not be_nil
      end
    end
  end

  describe "GET #show" do
    it "should return an object" do
      create(:end_note_file, id: 101, username: 'xyzxyz')
      get :show, id: 101, api_key: @api_key
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
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # describe "GET #update" do
  #   it "returns http success" do
  #     get :update
  #     expect(response).to have_http_status(:not_implemented)
  #   end
  # end

  describe "DELETE #destroy" do
    context "one own file out of three" do
      it "should delete one file" do
        file1 = create(:end_note_file, id: '1', username: 'test_key_user')
        file2 = create(:end_note_file, id: '2', username: 'test_key_user')
        file3 = create(:end_note_file, id: '3', username: 'test_key_user')
        delete :destroy, id: 1, api_key: @api_key
        expect(response).to have_http_status(:ok)
        get :index, api_key: @api_key
        expect(json['end_note_files']).to_not be nil
        expect(json['end_note_files'].count).to eq 2
      end
    end
    context "a file that belongs to some other user" do
      it "should return an error message" do
        file1 = create(:end_note_file, id: '1', username: @user.username)
        delete :destroy, id: 1, api_key: @api_key
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

end
