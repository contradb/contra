# require 'spec_helper.rb'

FactoryGirl.define do
  factory :program do
    title "Monday Night Set"
    user  { FactoryGirl.create :user }

    transient do
      dances []                 # convenience: can pass in a list of dances directly
    end
    after(:create) do |program, evaluator|
      evaluator.dances.each {|dance| program.append_new_activity(dance: dance)}
    end
  end
end
