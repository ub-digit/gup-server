FactoryGirl.define do
  factory :projects2publication do
    association :project, factory: [:project]
    association :publication_version, factory: [:publication_version]
  end

end
