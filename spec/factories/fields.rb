FactoryGirl.define do
  sequence :field_name do |n|
    "field_#{n}"
  end
  factory :field do
    name {generate :field_name}

    trait :required_name do
      name 'required'
    end

    factory :required_field, traits: [:required_name]
  end

end
