FactoryGirl.define do

  sequence :pubid do |n|
    "#{n}"
  end

  factory :publication do
    pubid {generate :pubid}
    association :publication_type, factory: [:publication_type]
    is_draft false
    is_deleted false
    title "A publication title"
    pubyear 1999

    trait :draft do
      is_draft true
    end

    trait :deleted do
      is_deleted true
    end

    factory :deleted_publication, traits: [:deleted]

    factory :draft_publication, traits: [:draft]
  end

end
