FactoryGirl.define do

  sequence :publication_type_code do |n|
    "publication_type_#{n}"
  end

  factory :publication_type do
    publication_type_code {generate :publication_type_code}
    article

    trait :article do
      form_template 'article'
    end

    factory :article_publication_type, traits: [:article]
  end

end
