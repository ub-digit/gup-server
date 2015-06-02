FactoryGirl.define do

  sequence :alternative_name_last_name do |n|
    "#{n}"
  end

  sequence :alternative_name_first_name do |n|
    "#{n}"
  end

  factory :alternative_name do
    association :person, factory: [:person]
    last_name {generate :alternative_name_last_name}
    first_name {generate :alternative_name_first_name}
  end

end
