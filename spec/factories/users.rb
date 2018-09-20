# require 'spec_helper.rb'

FactoryGirl.define do
  factory :user do
    name 'Fiddles McGee'
    sequence(:email){|n| "dancecaller#{n}@yahoo.com" }
    password '12345678'
  end
end
