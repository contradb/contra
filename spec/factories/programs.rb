# require 'spec_helper.rb'

FactoryGirl.define do
  factory :program do
    title "Monday Night Set"
    user  { FactoryGirl.create :user }

    transient do
      dances []
      text_activities []
    end

    after(:create) do |program, evaluator|
      evaluator.dances.each {|dance| program.append_new_activity(dance: dance)}
      evaluator.text_activities.each {|text| program.append_new_activity(text: text)}
    end
  end
end
