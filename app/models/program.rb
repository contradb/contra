# I tried to require 'test/unit/assertions', but couldn't make it work. Just rolled my own.


class Program < ApplicationRecord
  belongs_to :user
  validates :title, length: { in: 4..100 }  
  has_many :activities, dependent: :destroy
  has_many :dances, through: :activities
  accepts_nested_attributes_for :activities

  def activities_sorted
    self.activities.sort_by &:index
  end

  # verify that activities_sorted returns a list of activities,
  # indexed from 0, in ascending order. This should be true except
  # during surgery. (hey, do I need to worry about locking?)
  def activity_integrity?
    e = activities_sorted.to_enum
    i = 0
    loop do
      return false unless i == e.next.index
      i += 1
    end
    true
  end

  def activities_length
    maxx = -1
    activities.each {|a| maxx = a.index if a.index > maxx}
    return 1+maxx
  end

  # hash may contain attributes of Activities, except program and index (internal to here)
  # and ActiveRecord stuff
  def append_new_activity(hash)
    Private.assert !hash[:program]
    Private.assert !hash[:index]
    Activity.create(hash.merge({program: self, index: activities_length}))
    self.clear_association_cache
    self
  end

  module Private                # really not sure about this, guys. :)
    def self.assert x
      raise "failed assertion" unless x
    end
  end
end



