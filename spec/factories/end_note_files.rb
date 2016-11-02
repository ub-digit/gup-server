FactoryGirl.define do

  sequence :id do |n|
    n
  end

  sequence :username do |n|
    "xyzxy#{n}"
  end

  factory :end_note_file, class: EndNoteFile do
    id {generate :id}
    username 'test_key_user'
    xml '<?xml version="1.0" encoding="UTF-8" ?><xml><records><record></record><records></xml>'
    deleted_at nil
  end

  #factory :end_note_file do
  #  username "MyText"
  #  xml "MyText"
  #  deleted_at "2016-10-28 10:39:05"
  #end

end
