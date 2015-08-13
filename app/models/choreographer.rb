class Choreographer < ActiveRecord::Base
  has_many :dances

  before_destroy :reattribute_dances_to_unknown

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
