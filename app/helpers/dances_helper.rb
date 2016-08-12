# encoding: utf-8

# require 'v8'

module DancesHelper

  # stuck here because I need a UTF-8 file to stick it in. Sorry. 
  RotationMenuLabels = ["once", "1½",:___,"¼","½","¾","once","1¼","1½","1¾","twice"]

  ROTATION_TO_DEGREES = {
    "once"  => 360,
    "twice" => 720,
    "0"  =>   0,
    "¼"  =>  90,
    "½"  => 180,
    "¾"  => 270,
    "1"  => 360,
    "1¼" => 450,
    "1½" => 540,
    "1¾" => 630,
    "2"  => 720
  }.freeze
  def rotation_to_degrees(label) 
    ROTATION_TO_DEGREES[label.to_s] || 0
  end


  DEGREES_TO_ROTATION = {
    360  => "once",
    720  => "twice",
    0    => "0",
    90   => "¼",
    180  => "½",
    270  => "¾",
  # 360  => "1",
    450  => "1¼",
    540  => "1½",
    630  => "1¾",
  # 720  => "2"
  }.freeze
  def degrees_to_rotation(d) 
    DEGREES_TO_ROTATION[d] || (fail "bad degrees #{d}")
  end

  def degrees_to_places(d)
    d/90
  end






  ## Is this even called anymore? XXX
  # Take a list of option specifiers, where a spec can be:
  # :___ - it means add an option separator here  
  # symbol or string - add an option with label and value set to the symbol or string
  # [label,value] - add an option with label and value set to the symbol/strings specified
  # the "default" parameter compares against the value
  def options_html(specs,default=(specs and !specs.length.zero? and (specs[0].is_a?(Array) ? specs[0][1] : specs[0])))
    (specs.map {|spec| 
       label = spec.is_a?(Array) ? spec[0] : spec
       value = spec.is_a?(Array) ? spec[1] : spec
       if (:___ == label)
       then content_tag(:option, "──────────", disabled: "disabled" )
       else content_tag(:option, label, if (default===value)
                                        then {selected: "selected", value: value.to_s}
                                        else {value: value.to_s}
                                        end
                       )
       end
     }).join(" ");
  end



  def jsctx                     # javascript context
    return @context if @context
    @context = MiniRacer::Context.new
    %w(util move chooser param figure dance).each do |file|
      @context.load(Rails.root.join('app','assets','javascripts','libfigure',"#{file}.js"))
    end
    @context
  end


  def figure_txt(figure, terse: false) # takes a hash, returns a string
    jsctx.eval("figure_html_readonly(#{figure.to_json})")
  end

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
    JSON.generate(Dance.all.map do |dance|
                    {"title" => dance.title,
                     "choreographer" => dance.choreographer.name,
                     "id" => dance.id}
                  end)
  end
end
