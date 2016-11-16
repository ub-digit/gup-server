require 'rails_helper'

RSpec.describe V1::EndnoteFilesController, type: :controller do

  before :all do
    @user = User.create(username: "xanother", first_name: "Another", last_name: "Usersson", role: "USER")
  end

  before :each do
    @upload_root_dir = "#{Rails.root}/#{APP_CONFIG['file_upload_root_dir']}"
    FileUtils.mkdir_p(@upload_root_dir)

    @xml_file = fixture_file_upload('files/import130419.xml', 'application/xml')
    @xml_file2 = fixture_file_upload('files/import130418.xml', 'application/xml')
  end

  after :each do
    FileUtils.rm_rf(@upload_root_dir)
  end

  describe "GET #index" do
    context "with existing Endnote files for current user" do
      it "should return a list of Endnote files" do
        list = create_list(:endnote_file, 11)
        get :index, api_key: @api_key
        expect(json['endnote_files']).to_not be nil
        expect(json['endnote_files'][0]['id']).to be_an(Integer)
        expect(json['endnote_files'].count).to eq 11
      end
    end
    context "when files exist for current user and other users" do
      it "should return a list of Endnote files for current user only" do
        file1 = create(:endnote_file, id: '1', username: @user.username)
        file2 = create(:endnote_file, id: '2', username: @user.username)
        file3 = create(:endnote_file, id: '3', username: @user.username)
        file4 = create(:endnote_file, id: '4', username: @user.username)
        file5 = create(:endnote_file, id: '5', username: 'test_key_user')
        file6 = create(:endnote_file, id: '6', username: 'test_key_user')
        file7 = create(:endnote_file, id: '7', username: 'test_key_user')
        file8 = create(:endnote_file, id: '8', username: 'test_key_user')

        get :index, username: @user.username, api_key: @api_key
        expect(json['endnote_files']).to_not be nil
        expect(json['endnote_files'].count).to eq 4
      end
    end
    # context "with existing Endnote files for current user" do
    #   it "should return a list of Endnote files" do
    #     file = create(:endnote_file, )
    #     file = create(:endnote_file, id: '5', username: 'test_key_user')
    #     r1 = build(:endnote_record, )
    #     get :index, api_key: @api_key
    #     expect(json['endnote_files']).to_not be nil
    #     expect(json['endnote_files'][0]['id']).to be_an(Integer)
    #     expect(json['endnote_files'].count).to eq 11
    #   end
    # end
  end

  describe "POST #create" do
    context "with xml data from uploaded fake file" do
      it "should successfully create an EndnoteFile object" do
        post :create, file: @xml_file, api_key: @api_key
        expect(response).to have_http_status(:created)
        #pp "============"
        #pp json
        #pp "============"
        expect(json['endnote_file']).to_not be_nil
        expect(json['endnote_file']['username']).to_not be_nil
        expect(json['endnote_file']['username']).to eq 'test_key_user'
        expect(json['endnote_file']['name']).to_not be_nil
        expect(json['endnote_file']['name']).to eq 'import130419.xml'
      end
    end
    context "with xml data from uploaded authentic file" do
      it "should successfully create an EndnoteFile object" do
        post :create, file: @xml_file2, api_key: @api_key
        expect(response).to have_http_status(:created)
        expect(json['endnote_file']).to_not be_nil
        expect(json['endnote_file']['username']).to_not be_nil
        expect(json['endnote_file']['username']).to eq 'test_key_user'
        expect(json['endnote_file']['name']).to_not be_nil
        expect(json['endnote_file']['name']).to eq 'import130418.xml'
      end
    end
  end

  describe "GET #show" do
    it "should return an object" do
      create(:endnote_file, id: 101, username: 'xyzxyz')
      get :show, id: 101, api_key: @api_key
      expect(json["endnote_file"]).to_not be nil
      expect(json["endnote_file"]).to be_an(Hash)
    end

    context "an existing endnote_file" do
      it "should return a single Endnote file object" do
        obj = create(:endnote_file, id: 123)
        get :show, api_key: @api_key, id: obj.id
        expect(json['endnote_file']).to_not be nil
        expect(json['endnote_file']['id']).to be_an(Integer)
        expect(json['endnote_file']['id']).to eq 123
      end
    end
    context "a non existing Endnote file" do
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
        file1 = create(:endnote_file, id: '1', username: 'test_key_user')
        file2 = create(:endnote_file, id: '2', username: 'test_key_user')
        file3 = create(:endnote_file, id: '3', username: 'test_key_user')
        delete :destroy, id: 1, api_key: @api_key
        expect(response).to have_http_status(:ok)
        get :index, api_key: @api_key
        expect(json['endnote_files']).to_not be nil
        expect(json['endnote_files'].count).to eq 2
      end
    end
    context "a file that belongs to some other user" do
      it "should return an error message" do
        file1 = create(:endnote_file, id: '1', username: @user.username)
        delete :destroy, id: 1, api_key: @api_key
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
    context "when a file is deleted" do
      context "and a record within belongs to a publication" do
        it "the record should not be deleted" do
          file = build(:endnote_file)
          record = build(:endnote_record)
          publication = create(:publication)
          record.publication_id = publication.id
          record.save
          file.endnote_records << record
          file.save
          delete :destroy, id: file.id, api_key: @api_key
          r = EndnoteRecord.find_by(id: record.id)
          expect(response).to have_http_status(:ok)
          expect(r).to_not be nil
          expect(r.publication_id).to eq publication.id
        end
      end
      context "but a record within is also in other file" do
        it "the record should not be deleted" do
          my_checksum = '9999999999'
          record = create(:endnote_record, id: 2, checksum: my_checksum)
          file1 = build(:endnote_file)
          file1.endnote_records << record
          file1.save
          file2 = build(:endnote_file, id: 2)
          file2.endnote_records << record
          file2.save
          delete :destroy, id: file1.id, api_key: @api_key
          r = EndnoteRecord.find_by(id: record.id)
          expect(response).to have_http_status(:ok)
          expect(r).to_not be nil
          expect(r.checksum).to eq record.checksum
        end
      end
      context "and record is only in that file" do
        it "should be deleted" do
          file = build(:endnote_file)
          record = create(:endnote_record, id: 999)
          file.endnote_records << record
          file.save
          expect(file.endnote_records.count).to eq 1
          delete :destroy, id: file.id, api_key: @api_key
          expect(response).to have_http_status(:ok)

          r = EndnoteRecord.find_by(id: record.id)
          expect(r).to be nil
        end
      end
    end
  end
end
