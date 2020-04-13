# require 'spec_helper.rb'

FactoryGirl.define do
  factory :user do
    sequence(:name) {|n| "Fiddles McGee #{n}" }
    sequence(:email){|n| "dancecaller#{n}@yahoo.com" }
    password '12345678'
  end
end
