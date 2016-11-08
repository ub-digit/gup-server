FactoryGirl.define do

  sequence :endnote_record_id do |n|
    n
  end

  factory :endnote_record do
    id {generate :endnote_record_id}
    checksum "MyText"
    username 'test_key_user'
  end
end
