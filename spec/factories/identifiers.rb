FactoryGirl.define do

  sequence :identifier_value do |n|
    "#{n}"
  end

  factory :identifier do
    association :person, factory: [:person]
    association :source, factory: [:source]
    value {generate :identifier_value}

    trait :xkonto do
      source {Source.where(name: "xkonto").first || create(:source, name: 'xkonto')}
    end

    factory :xkonto_identifier, traits: [:xkonto]
  end

end
