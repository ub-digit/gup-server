FactoryGirl.define do

  sequence :id do |n|
    n
  end

  sequence :username do |n|
    "xyzxy#{n}"
  end

  factory :endnote_file, class: EndnoteFile do
    id {generate :id}
    username 'test_key_user'
    xml '<?xml version="1.0" encoding="UTF-8" ?><xml><records><record></record><records></xml>'
  end

end
