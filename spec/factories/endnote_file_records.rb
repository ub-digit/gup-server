FactoryGirl.define do

  sequence :position do |n|
    n
  end

  factory :endnote_file_record do
    association :endnote_file, factory: [:endnote_file]
    association :endnote_record, factory: [:endnote_record]
    position {generate :position}
  end

end
