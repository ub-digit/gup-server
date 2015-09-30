FactoryGirl.define do

  sequence :pubid do |n|
    "#{n}"
  end

  factory :publication do
    pubid {generate :pubid}
    publication_type 'journal-articles'
    is_deleted false
    published_at DateTime.now
    biblreviewed_at DateTime.now
    title "A publication title"
    pubyear 1999
    sourcetitle "Source title"
    publanguage "EN"

    trait :draft do
      published_at nil
    end

    trait :deleted do
      is_deleted true
    end

    trait :unreviewed do
      biblreviewed_at nil
      bibl_review_start_time DateTime.now - 1
    end

    factory :deleted_publication, traits: [:deleted]

    factory :draft_publication, traits: [:draft]

    factory :unreviewed_publication, traits: [:unreviewed]

  end

end
