FactoryGirl.define do
  sequence :publication_type_code do |n|
    "publication_type_#{n}"
  end
  factory :publication_type do
    
    ref_options 'ISREF'
    code {generate :publication_type_code}

    trait :required_field do
      after :build do |p|
        p.fields2publication_types << create(:required_field_relation, publication_type: p)
      end
    end

    trait :publication_version do
      after :build do |p|
        p.fields2publication_types << create(:title_field_relation, publication_type: p)
      end
    end

    factory :test_publication_type, traits: [:required_field]

    factory :publication_version_type, traits: [:publication_version]
  end

end
