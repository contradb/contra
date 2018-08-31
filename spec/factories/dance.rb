FactoryGirl.define do
  factory :dance do
    title      'The Rendevouz'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    hook 'pioneered slide progression'
    preamble 'a preamble appears here'
    figures_json '[{"parameter_values":["neighbors","balance",16],"move":"swing"},{"parameter_values":[true, 8],"move":"long lines"},{"parameter_values":["ladles",true,540,8],"move":"do si do"},{"parameter_values":["partners","balance",16],"move":"swing"},{"parameter_values":[true,360,8],"move":"circle"},{"parameter_values":[true,2],"move":"slide along set"},{"parameter_values":[true,270,6],"move":"circle", "progression": 1}]'
    # todo: put this progression on the right figure - the slide!
  end

  factory :box_the_gnat_contra, class: Dance do
    title      'Box the Gnat Contra'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    hook 'stompy fun'
    preamble 'blah blah blah'
    figures_json '[{"parameter_values":["neighbors",true,true,8],"move":"box the gnat"},{"parameter_values":["partners",true,false,8],"move":"box the gnat"},{"parameter_values":["neighbors","balance",16],"move":"swing"},{"parameter_values":["ladles",true,540,8],"move":"allemande"},{"parameter_values":["partners","none",8],"move":"swing"},{"parameter_values":["across",8],"move":"right left through"},{"parameter_values":["ladles",true,"across",8],"move":"chain", "progression": 1}]'
    notes 'swat the flea variation'
  end

  factory :call_me, class: Dance do
    title "Call Me"
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'Becket ccw'
    figures_json '[{"parameter_values":["across",8],"move":"right left through"},{"parameter_values":["ladles",true,"across",8],"move":"chain"},{"parameter_values":[false,360,"",8],"move":"star","note":"look for new neighbor"},{"parameter_values":["neighbors","none",8],"move":"swing"},{"parameter_values":[true,270,8],"move":"circle"},{"parameter_values":["ladles",0.5,"across",8],"move":"hey"},{"parameter_values":["partners","balance",16],"move":"swing", "progression": 1}]'
  end

  factory :you_cant_get_there_from_here, class: Dance do
    title "You Can't Get There From Here"
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":["everyone",4],"move":"balance","note":"the wave"},{"parameter_values":["neighbors",true,270,4],"move":"allemande","note":"to"},{"parameter_values":["ladles",0],"move":"form long waves","note":"the wave"},{"parameter_values":["everyone",4],"move":"balance"},{"parameter_values":["neighbors",true,270,4],"move":"allemande","note":""},{"parameter_values":[false,"across",false,"gentlespoons",false,"neighbors",0],"move":"form an ocean wave"},{"parameter_values":["everyone",4],"move":"balance","note":"the wave"},{"parameter_values":["neighbors","none",12],"move":"swing"},{"parameter_values":[true,270,8],"move":"circle"},{"parameter_values":["partners","none",8],"move":"swing"},{"parameter_values":[true,270,8],"move":"circle"},{"parameter_values":["neighbors",true,630,8],"move":"do si do"},{"parameter_values":[0],"move":"progress"},{"parameter_values":[false,"across",false,"ladles",false,"neighbors",0],"move":"form an ocean wave","note":"in short waves"}]'
  end

  factory :dance_with_empty_figure, class: Dance do # note that empty figure is no longer officially supported -dm 07-30-2018
    title      'Emptyish'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":["neighbors","balance",16],"move":"swing"}, {"parameter_values":[]}]'
  end

  factory :dance_with_a_swing, class: Dance do
    title      'Monofigure'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":["neighbors","balance",16],"move":"swing"}]'
  end

  factory :dance_with_pair, class: Dance do
    transient do
      pair {'2nd shadows'}
    end
    sequence(:title) {|n| "Dance With Pair#{n}"}
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json {"[{\"parameter_values\":[#{pair.inspect},\"balance\",16],\"move\":\"swing\"}]"}
  end

  factory :dance_with_all_shadows_and_neighbors, class: Dance do
    sequence(:title) {|n| "All Shadows and Neighbors#{n}"}
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json {'[{"parameter_values":["neighbors","none",8],"move":"swing"}, {"parameter_values":["prev neighbors","none",8],"move":"swing"}, {"parameter_values":["neighbors","none",8],"move":"swing"}, {"parameter_values":["next neighbors","none",8],"move":"swing"}, {"parameter_values":["3rd neighbors","none",8],"move":"swing"}, {"parameter_values":["4th neighbors","none",8],"move":"swing"}, {"parameter_values":["shadows","none",8],"move":"swing"}, {"parameter_values":["2nd shadows","none",8],"move":"swing"}]'}
  end

  factory :dance_with_a_rory_o_more, class: Dance do
    title      'Just Rory'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":["neighbors",true,false,8],"move":"Rory O\'More"}]'
  end

  factory :dance_with_a_circle_right, class: Dance do
    title      'Just Circle Right'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":[false,270,8],"move":"circle"}]'
  end

  factory :dance_with_a_gentlespoons_allemande_left_once, class: Dance do
    title      'Just Allemande'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":["gentlespoons",false,360,8],"move":"allemande"}]'
  end

  factory :dance_with_a_custom, class: Dance do
    transient do
      custom_text {'this is my custom text'}
      figure_note { nil }
    end
    sequence(:title) {|n| "CustomDance#{n}Boop"}
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    # I feel like this is the Right Way to do tricky quote-in-quote
    # json in this file. Should probably migrate everyone else at some
    # point. -dm 06-24-2018
    figures_json {%([{"parameter_values":[#{custom_text.to_json}, 8],"move":"custom"#{if figure_note then ', "note":'+figure_note.to_json else '' end}}])}
  end

  factory :dance_with_a_wrist_grip_star, class: Dance do
    sequence(:title) {|n| "StarDance#{n}"}
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json {'[{"parameter_values":[true,360,"wrist grip",8],"move":"star"}]'}
  end


  factory :dance_with_a_down_the_hall, class: Dance do
    transient do
      march_facing {'forward'}
      down_the_hall_ender {'turn-couple'}
    end
    sequence(:title) {|n| "DownTheHallDance#{n}"}
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json {"[{'parameter_values':['#{march_facing}','#{down_the_hall_ender}',8],'move':'down the hall'}]".gsub("'", '"')}
  end

  factory :dance_with_a_full_hey, class: Dance do
    sequence(:title) {|n| "HeyDance#{n}"}
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json {'[{"parameter_values":["gentlespoons",1.0,"across",8],"move":"hey"}]'}
  end

  factory :dance_with_a_see_saw, class: Dance do
    sequence(:title) {|n| "SeeSawDance#{n}"}
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json {'[{"parameter_values":["ladles",false,360,8],"move":"do si do"}]'}
  end

  factory :dance_with_a_do_si_do, class: Dance do
    sequence(:title) {|n| "DoSiDoDance#{n}"}
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json {'[{"parameter_values":["ladles",true,360,8],"move":"do si do"}]'}
  end

  factory :dance_with_zero_figures, class: Dance do
    title {'zero'}
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json {'[]'}
  end

  factory :malicious_dance, class: Dance do
    # simulate xss attack by embedding html in dance elements.
    # all the angle-brackety-things should be passed through as literals.
    title      'Malicious Dance'
    user { FactoryGirl.create(:user) }
    choreographer { FactoryGirl.create(:choreographer) }
    start_type 'improper'
    figures_json '[{"parameter_values":["<b>neighbors</b>","balance",16],"move":"swing", "note":"this should not be <b>bold</b>"}]'
  end
end
