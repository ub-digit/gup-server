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

    trait :orcid do
      source {Source.where(name: "orcid").first || create(:source, name: 'orcid')}
    end
    
    factory :xkonto_identifier, traits: [:xkonto]
    factory :orcid_identifier, traits: [:orcid]

  end

end
