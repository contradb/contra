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

  # you! manually sync changes to dances.coffee!
  def move_cares_about_rotations(s)
    [:do_si_do, :see_saw, :allemande_right, :allemande_left, :gypsy_right_shoulder, :gypsy_left_shoulder].include?(s.intern)
  end

  # you! manually sync changes to dances.coffee!
  def move_cares_about_places(s)
    [:circle_left, :circle_right, :star_left, :star_right].include?(s.intern)
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


def figure_txt(figure, terse: false) # takes a string, returns a string
  if ( /^\s*$/ =~ figure)
  then terse ? "" : "empty figure '#{figure}'".html_safe
  else 
    begin
      o = JSON.parse figure
    rescue JSON::ParserError => e
      terse ? "error" : "ParserError '#{e}' on '#{figure}'"
    else
      if !o
      then terse ? "error" : "messed-up figure".html_safe
      else 
        
        move    = if o['move'] and (o['move'] != 'custom') then o['move'] else '' end
        who     = if "everybody" === o['who'] 
                    then '' 
                    elsif terse
                    then (o['who'] == 'ones') ? 
                         '1s' : 
                         ((o['who'] == 'twos') ? 
                            '2s' : 
                            o['who'][0] + ". ")
                    else o['who'] 
                  end
        beats   = o['beats']   || nil
        notes   = !o['notes'] ? '' :
                  ((terse && (o['notes'].length >=13)) ?
                    o['notes'][0..10] + "..." :
                    o['notes'])
        degrees = o['degrees']
        deg_txt = if !degrees
                  then ""
                  elsif terse
                  then ""
                  elsif move_cares_about_places(move)
                  then "#{degrees_to_places(degrees)} places"
                  elsif move_cares_about_rotations(move)
                  then "#{degrees_to_rotation(degrees)}"
                  else "#{degrees} degrees"
                  end
        balance = if !o['balance'] 
                  then '' 
                  elsif terse 
                  then "b+" 
                  else 'balance + '
                  end
        beat_str = ((beats == 8) || terse) ? "" : "for #{beats}"
        if beats > 0
          then "#{who} #{balance}#{move} #{deg_txt} #{beat_str} #{notes}"
          else terse ? "" : "~".html_safe
        end
      end
    end
  end
end
