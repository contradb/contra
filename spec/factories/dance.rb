FactoryGirl.define do
  factory :dance do
    title      'The Rendevouz'
    user
    choreographer
    start_type 'improper'
    figures_json '[{"who":"neighbor","move":"swing","beats":16,"balance":true},{"who":"everybody","move":"long_lines","beats":8},{"who":"ladles","move":"chain","beats":8,"notes":"or ladles swing"},{"who":"partner","move":"swing","beats":16,"balance":true},{"who":"everybody","move":"circle_left","beats":8,"degrees":360},{"who":"everybody","move":"custom","beats":8,"notes":"slide left to new and circle 3 places"}]'
  end
end

