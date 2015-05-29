FactoryGirl.define do

  sequence :identifier_value do |n|
    "#{n}"
  end

  factory :identifier do
    association :person, factory: [:person]
    association :source, factory: [:source]
    value {generate :identifier_value}
  end

end
