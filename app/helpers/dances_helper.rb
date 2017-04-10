# encoding: utf-8
require 'jslibfigure'


module DancesHelper
  # input: an array of possibly non-html-safe strings
  # output: a string representation of the array with brackets and
  #         quotes and properly html-safe internal strings.
  def a_to_safe_str(a)
    s = '['.html_safe
    first_time = true
    a.each do |e|
      s << ','.html_safe unless first_time
      s << '"'.html_safe
      s << e
      s << '"'.html_safe
      first_time = false;
    end
    s << ']'.html_safe
    s
  end

  def dance_autocomplete_hash_json
    # TODO
    JSON.generate(Dance.all.map do |dance|
                    {"title" => dance.title,
                     "choreographer" => dance.choreographer.name,
                     "id" => dance.id}
                  end)
  end
end
