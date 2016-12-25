# require 'spec_helper.rb'

FactoryGirl.define do
  factory :user do
    name 'Sailee Sims'
    sequence(:email){|n| "spam.me.harder.#{n}@gmail.com" }
    password '12345678'
  end
end

