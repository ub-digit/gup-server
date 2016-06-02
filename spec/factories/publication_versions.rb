FactoryGirl.define do
  factory :publication_version do
    association :publication_type, factory: [:publication_version_type]
    biblreviewed_at DateTime.now
    title "A publication title"
    pubyear 2013
    sourcetitle "Source title"
    publanguage "EN"
    association :publication, factory: [:publication]
    created_by 'test_key_user'
    ref_value 'NA'
    category_hsv_local [1]

    trait :unreviewed do
      biblreviewed_at nil
    end

    factory :unreviewed_publication_version, traits: [:unreviewed]
  end
end
