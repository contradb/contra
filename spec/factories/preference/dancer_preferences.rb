FactoryGirl.define do
  factory :dancer_preference, class: 'Preference::Dancer' do
    type 'Preference::Dancer'
    term 'gentlespoons'
    substitution 'gents'
  end
end
