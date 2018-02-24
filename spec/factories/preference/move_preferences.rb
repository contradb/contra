FactoryGirl.define do
  factory :move_preference, class: 'Preference::Move' do
    type 'Preference::Move'
    term 'gyre'
    substitution 'darcy'
  end
end
