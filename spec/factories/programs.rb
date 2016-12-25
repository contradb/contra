# require 'spec_helper.rb'

FactoryGirl.define do
  factory :program do
    title "Monday Night Set"
    user  { FactoryGirl.create :user }
  end
end
