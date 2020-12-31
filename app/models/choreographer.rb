class Choreographer < ApplicationRecord
  has_many :dances, -> { order Arel.sql("lower(title)") }

  validates :name, length: { in: 4..100 }

  before_destroy :reattribute_dances_to_unknown

  enum publish: {never: 0, sometimes: 5, always: 10, deceased_and_unknown: 9}, _prefix: true

  # human readable website
  def website_label
    if website
      w = String.new(website)
      w.slice!(%r{^https?://})
      w
    end
  end

  # machine readable website
  def website_url
    if website
      (website =~ %r{^https?://}) ? website : "http://#{website}"
    end
  end

  protected
   def reattribute_dances_to_unknown
     # attribute my dances to 1 - the unknown choreographer
     if 1 != self.id then
       self.dances.each { |d|
         puts "we're rejiggering #{d.title}'s choreographer from #{self.id} to 1."
         d.choreographer_id = 1
         d.save
         return self
       } 
     end
   end

end
