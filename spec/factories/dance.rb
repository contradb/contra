FactoryGirl.define do
  factory :dance do
    title      'The Rendevouz'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":["neighbors",true,16],"move":"swing"},{"parameter_values":[8],"move":"long lines"},{"parameter_values":["ladles",true,540,8],"move":"do si do"},{"parameter_values":["partners",true,16],"move":"swing"},{"parameter_values":[true,360,8],"move":"circle"},{"parameter_values":[true,2],"move":"slide along set"},{"parameter_values":[true,270,6],"move":"circle"}]'
  end

  factory :dance_with_a_swing, class: Dance do
    title      'Monofigure'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":["neighbors",true,16],"move":"swing"}]'
  end

  factory :old_figure_format_dance, class: Dance do
    title      'The Rendevouz'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"who":"neighbor","move":"swing","beats":16,"balance":true},{"who":"everybody","move":"long_lines","beats":8},{"who":"ladles","move":"chain","beats":8,"notes":"or ladles swing"},{"who":"partner","move":"swing","beats":16,"balance":true},{"who":"everybody","move":"circle_left","beats":8,"degrees":360},{"who":"everybody","move":"custom","beats":8,"notes":"slide left to new and circle 3 places"}]'
  end

  factory :box_the_gnat_contra, class: Dance do
    title      'Box the Gnat Contra'
    user { FactoryGirl.create(:user) }
    choreographer { Choreographer.find_by(name: "Becky Hill") ||
                    FactoryGirl.create(:choreographer, name: "Becky Hill") }
    start_type 'improper'
    figures_json '[{"parameter_values":["neighbors",true,true,8],"move":"box the gnat"},{"parameter_values":["partners",true,false,8],"move":"swat the flea"},{"parameter_values":["neighbors",true,16],"move":"swing"},{"parameter_values":["ladles",true,540,8],"move":"allemande"},{"parameter_values":["partners",false,8],"move":"swing"},{"parameter_values":["across",8],"move":"right left through"},{"parameter_values":["ladles","across",8],"move":"chain"}]'
    notes 'swat the flea variation'
  end

  factory :call_me, class: Dance do
    title "Call Me"
    choreographer { Choreographer.find_by(name: "Cary Ravitz") ||
                    FactoryGirl.create(:choreographer, name: "Cary Ravitz") }
    start_type 'Becket ccw'
    figures_json '[{"parameter_values":["across",8],"move":"right left through"},{"parameter_values":["ladles","across",8],"move":"chain"},{"parameter_values":[false,360,"",8],"move":"star","note":"look for new neighbor"},{"parameter_values":["neighbors",false,8],"move":"swing"},{"parameter_values":[true,270,8],"move":"circle"},{"parameter_values":["ladles","across",8],"move":"half hey"},{"parameter_values":["partners",true,16],"move":"swing"}]'
  end
end

