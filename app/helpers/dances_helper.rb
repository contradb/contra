# encoding: UTF-8

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
  }
  def rotation_to_degrees(label) 
    ROTATION_TO_DEGREES[label.to_s] || 0
  end


  # IMPORTANT: this constant is manually synced to the equivalent server-side constant
  # in dances.coffee!
  WHO = [:everybody, :partner, :neighbor, :ladles, :gentlespoons, :ones, :twos].freeze;

  # XXX uncalled?
  # this has GOT to be obsolete and needs a client-side...XXX
  BALANCEABLE = {petronella: true, balance_the_ring: true,
    box_the_gnat: true, swat_the_flea: true, california_twirl: true, arizona_twirl: true,
    swing: true, pull_by_left: true, pull_by_right: true,
  }.freeze


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
end
