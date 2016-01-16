FactoryGirl.define do
  factory :activity do
    index   
    program 
    dance nil
    sequence(:text){|n| 'announcement #' + (n+1).to_s }
  end
end
