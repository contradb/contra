FactoryGirl.define do
  factory :blog do
    sequence (:title) {|i| "ContraDB Blogs are a Thing (part #{i})"}
    body "Blog articles let us notify users about new features and changes"
    user  { FactoryGirl.create :user, blogger: true }
  end
end
