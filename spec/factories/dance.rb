FactoryGirl.define do
  factory :dance do
    title      'The Rendevouz'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":["neighbors",true,16],"move":"balance and swing"},{"parameter_values":[8],"move":"long lines"},{"parameter_values":["ladles",true,540,8],"move":"do si do"},{"parameter_values":["partners",true,16],"move":"balance and swing"},{"parameter_values":[true,360,8],"move":"circle"},{"parameter_values":[true,2],"move":"slide"},{"parameter_values":[true,270,6],"move":"circle three places"}]'
  end

  factory :old_figure_format_dance, class: Dance do
    title      'The Rendevouz'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"who":"neighbor","move":"swing","beats":16,"balance":true},{"who":"everybody","move":"long_lines","beats":8},{"who":"ladles","move":"chain","beats":8,"notes":"or ladles swing"},{"who":"partner","move":"swing","beats":16,"balance":true},{"who":"everybody","move":"circle_left","beats":8,"degrees":360},{"who":"everybody","move":"custom","beats":8,"notes":"slide left to new and circle 3 places"}]'
  end
end

