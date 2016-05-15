FactoryGirl.define do
  factory :choreographer do
    sequence(:name) do |n|
      a = ["unknown", "Cary Ravitz", "Dan Pearl", "Nicholas Rockstroh", "David Kaynor", "Gene Hubert", "Becky Hill", "Chart Guthrie", "Jim Hemphill", "Bob Green", "Naresh Keswani", "Sue Rosen", "Joseph Pimentel", "Lisa Greenleaf", "Jim Kitch", "Dave Morse", "Lisa Sieverts", "Ted Sannella", "Chestnut", "Tom Hinds", "Joe Wilkie", "Seth Tepfer"]
      n < a.length ? a[n] : "the #{'real'*(n-a.length)} Becky Hill"
    end
  end
end

