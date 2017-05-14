FactoryGirl.define do
  factory :choreographer do
    sequence(:name) do |n|
      a = ["Cary Ravitz", "Dan Pearl", "Nicholas Rockstroh", "David Kaynor", "Gene Hubert", "Becky Hill", "Chart Guthrie", "Jim Hemphill", "Bob Green", "Naresh Keswani", "Sue Rosen", "Joseph Pimentel", "Lisa Greenleaf", "Jim Kitch", "Dave Morse", "Lisa Sieverts", "Ted Sannella", "Tom Hinds", "Joe Wilkie", "Seth Tepfer"]
      "#{'Turbo '*(n / a.length)} #{a[n % a.length]}"
    end
  end

  factory :friendly_choreographer, class: :choreographer do
    sequence(:name) do |n| "choreographer-#{1000+n}" end
    publish :always
    website "www.friendly-choreographer.com/dances"
  end
end

