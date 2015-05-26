FactoryGirl.define do

  sequence :person_last_name do |n|
    "last_name_#{n}"
  end

  factory :person do
    last_name {generate :person_last_name}
  end

end
