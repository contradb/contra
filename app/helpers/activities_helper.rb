require 'json'

module ActivitiesHelper
  def self.activities_to_json_for_editing (activities)
    raise "bad activities param: #{activities.inspect}" unless activities.respond_to? :map
    JSON.generate(
      activities.map do |a|
        h = {}
        h['text'] = a.text         if a.text
        h['dance_id'] = a.dance_id if a.dance_id
        h
      end
    )
  end
  def self.dances_to_json_for_selecting ()
    JSON.generate(
      Dance.all.map do |d|
        {"label" => d.title, "value" => d.id}
      end
    )
  end
end
