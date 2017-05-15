# require 'spec_helper.rb'

FactoryGirl.define do
  factory :user do
    name 'Nate Rockstraw'
    sequence(:email){|n| "spam.me.harder.#{n}@gmail.com" }
    password '12345678'
  end
end

