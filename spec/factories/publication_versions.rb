FactoryGirl.define do
  factory :publication_version do
    publication_type 'journal-articles'
    biblreviewed_at DateTime.now
    title "A publication title"
    pubyear 1999
    sourcetitle "Source title"
    publanguage "EN"
    association :publication, factory: [:publication]

    trait :unreviewed do
      biblreviewed_at nil
    end

    factory :unreviewed_publication_version, traits: [:unreviewed]
  end
end
