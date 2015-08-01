# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


# IMPORTANT: this constant is manually synced to the equivalent server-side constant
# in dances_helper.rb!
WHO = ["everybody", "partner", "neighbor", "ladles", "gentlespoons", "ones", "twos"]

move_menu_options = (v) ->
  who = switch 
          when (v < 0) or (v>=WHO.length) then "everybody" # shouldn't ever happen
          else WHO[v]
  labels = switch who
             when "everybody" then [
               "circle_left", "circle_right", "star_left", "star_right", "petronella",
               "balance_the_ring", "to_ocean_wave", "right_left_through"]
             when "partner", "neighbor" then [ "swing",
               "do_si_do", "see_saw", "allemande_right", "allemande_left",
               "gypsy_right_shoulder", "gypsy_left_shoulder",
               "pull_by_right", "pull_by_left", 
               "box_the_gnat", "swat_the_flea", "california_twirl", "arizona_twirl"]
             when "ladles", "gentlespoons" then [ "chain",
               "do_si_do", "see_saw", "allemande_right", "allemande_left",
               "gypsy_right_shoulder", "gypsy_left_shoulder",
               "chain", "pull_by_right", "pull_by_left",
               "mad_robin", "hey", "half_a_hey", 
               "allemande_left_with_orbit", "allemande_right_with_orbit"]
             when "ones", "twos" then ["swing"]
  console.log(who)
  ("<option>"+label+"</option>" for label in labels).join(" ")
 
$ ->
  $(".who_edit").change((e) -> $( e.target ).siblings(".move_edit").html(move_menu_options( e.target.value)))
