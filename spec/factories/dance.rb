FactoryGirl.define do
  factory :dance do
    title      'The Rendevouz'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":["neighbors",true,16],"move":"swing"},{"parameter_values":[true, 8],"move":"long lines"},{"parameter_values":["ladles",true,540,8],"move":"do si do"},{"parameter_values":["partners",true,16],"move":"swing"},{"parameter_values":[true,360,8],"move":"circle"},{"parameter_values":[true,2],"move":"slide along set"},{"parameter_values":[true,270,6],"move":"circle"}]'
  end

  factory :dance_with_empty_figure, class: Dance do
    title      'Emptyish'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":["neighbors",true,16],"move":"swing"}, {"parameter_values":[]}]'
  end

  factory :dance_with_a_swing, class: Dance do
    title      'Monofigure'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":["neighbors",true,16],"move":"swing"}]'
  end

  factory :dance_with_a_rory_o_moore, class: Dance do
    title      'Just Rory'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":["neighbors",true,false,8],"move":"Rory O\'Moore"}]'
  end

  factory :dance_with_a_circle_right, class: Dance do
    title      'Just Circle Right'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":[false,270,8],"move":"circle"}]'
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
    user { FactoryGirl.create(:user) }
    choreographer { Choreographer.find_by(name: "Cary Ravitz") ||
                    FactoryGirl.create(:choreographer, name: "Cary Ravitz") }
    start_type 'Becket ccw'
    figures_json '[{"parameter_values":["across",8],"move":"right left through"},{"parameter_values":["ladles","across",8],"move":"chain"},{"parameter_values":[false,360,"",8],"move":"star","note":"look for new neighbor"},{"parameter_values":["neighbors",false,8],"move":"swing"},{"parameter_values":[true,270,8],"move":"circle"},{"parameter_values":["ladles",0.5,"across",8],"move":"hey"},{"parameter_values":["partners",true,16],"move":"swing"}]'
  end
end

