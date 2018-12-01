FactoryGirl.define do
  factory :tag do
    sequence(:name) {|n| "edgy#{n}" }
  end
end
