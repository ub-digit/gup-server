FactoryGirl.define do
  factory :fields2publication_type do
    required_rule
    association :publication_type, factory: [:publication_type]
    association :field, factory: :field

    trait :required_rule do
      rule 'R'
    end

    trait :required_relation do
      association :field, factory: :required_field, strategy: :find_or_create
    end

    trait :title_relation do
      association :field, factory: :field, strategy: :find_or_create, name: 'title'
    end

    factory :required_field_relation, traits: [:required_rule, :required_relation]

    factory :title_field_relation, traits: [:required_rule, :title_relation]
  end

end
