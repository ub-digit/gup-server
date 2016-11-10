FactoryGirl.define do

  sequence :source_name do |n|
    "source_#{n}"
  end

  factory :source do
    name {generate :source_name}

    trait :orcid do
      name "orcid"
    end

    trait :xkonto do
      name "xkonto"
    end

    factory :orcid_source, traits: [:orcid]
    factory :xkonto_source, traits: [:xkonto]

  end

end
