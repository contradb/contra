# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


# IMPORTANT: this constant is manually synced to the equivalent server-side constant
# in dances_helper.rb!
# WHOs elements must be composed of letters, digits, or underscores
WHO = ["everybody", "partner", "neighbor", "ladles", "gentlespoons", "ones", "twos"]

# If adding here, be sure to add one or more "who" reactors in move_menu_options too,
# and there'll probably be a ruby-side version of this list that needs to be manually synced
# as well. 
# MOVES elements must be composed of letters, digits, or underscores
MOVES = ["circle_left", "circle_right", "star_left", "star_right", "petronella", "balance_the_ring", "to_ocean_wave", "right_left_through", "swing", "do_si_do", "see_saw", "allemande_right", "allemande_left", "gypsy_right_shoulder", "gypsy_left_shoulder", "pull_by_right", "pull_by_left", "box_the_gnat", "swat_the_flea", "california_twirl", "arizona_twirl", "chain", "mad_robin", "hey", "half_a_hey", "allemande_left_with_orbit", "allemande_right_with_orbit"] 

# not yet called XXX
# returns values [type, default]
move_parameter = (move) ->
  console.log("move_parameter(#{move})")
  switch move
    when "circle_left", "circle_right"       then ["places","270"]
    when "star_left", "star_right"           then ["places","360"]
    when "allemande_right", "allemande_left" then ["rotations", "540"]
    when "do_si_do", "see_saw"               then ["rotations", "360"]
    when "gypsy_left_shoulder"               then ["rotations", "360"]
    when "gypsy_right_shoulder"              then ["rotations", "360"]
    when "allemande_right_with_orbit"        then ["rotations", "540"]
    when "allemande_left_with_orbit"         then ["rotations", "540"]
    else [null, 0]


# some moves care about places, some moves care about rotations, and
# some moves care about neither, but none care about both. (It's just
# syntactic sugar)
move_cares_about_rotations = (move) ->
    switch move
      when "do_si_do", "see_saw", "allemande_right", "allemande_left" then true
      else false

move_cares_about_rotations = (move) ->
    switch move
      when "do_si_do", "see_saw", "allemande_right", "allemande_left", "gypsy_right_shoulder", "gypsy_left_shoulder" then true
      else false

move_cares_about_places = (move) ->
    switch move
      when "circle_left", "circle_right", "star_left", "star_right" then true
      else false


move_menu_options = (who) ->
  labels = switch who
             # if adding to this list, be sure to add the move to the MOVES array above,
             # and follow instructions there. 
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
               # "allemande_left_with_orbit", "allemande_right_with_orbit",
               "mad_robin", "hey", "half_a_hey"]
             when "ones", "twos" then ["swing"]
  ("<option>"+label+"</option>" for label in labels).join(" ")

editor_to_string = ($editor) ->
  who       = $editor.find(".who_edit").val()
  move      = $editor.find(".move_edit").val()
  beats     = $editor.find(".beat_edit").val()
  balance   = $editor.find(".balance_edit").prop("checked")
  rotations = $editor.find(".rotations_edit").val()
  places    = $editor.find(".places_edit").val()
  degrees   = switch
              when move_cares_about_places(move) then "#{places} degrees "
              when move_cares_about_rotations(move) then "#{rotations} degrees "
              else ""
  if balance then balance_s = "balance+" else balance_s = "" 
  "#{who} #{balance_s}#{move} #{degrees}for #{beats}"

 
# takes DOM who editor 
# builds move menu
manage_who_change = (who) ->
  console.log("manage_who_change()")
  $move = $( who ).siblings(".move_edit")
  $move.html(move_menu_options( who.value))
  manage_move_change($move[0])

# takes DOM move editor 
manage_move_change = (move) ->
    console.log("manage_move_change()")
    $move = $(move)
    $move.siblings(".rotations_edit").toggle( move_cares_about_rotations( $move.val() ) )
    $move.siblings(".rotations_edit").val(move_parameter($move.val())[1])
    $move.siblings(".places_edit").toggle   ( move_cares_about_places(    $move.val() ) )
    $move.siblings(".places_edit").val(move_parameter($move.val())[1])

parse_figure_string = (str) ->
  # parse a string into object
  # parsing strategy: use javascript regexp facility
  # str input example
  # ladles allemande_left 360 degrees for 8
  # str format
  # WHO ["balance+"]MOVE ["\d+ degrees"] for "\d+"
  a = /(\w+)\W+(balance\+)?(\w+)\W+(\d+\W+degrees\W+)?for\W+(\d+)/.exec(str)
  console.log("tried '#{str}'")
  if a then   console.log("matched #{a}") else console.log ("did not match")


$ ->
  $(".who_edit").change((e) -> manage_who_change e.target)
  $(".move_edit").change((e) -> manage_move_change e.target)
  $(".who_edit").each((i) -> manage_who_change( this )) # workaround until we can load defaults from DB?
  # cool! change() gets called on contailers when children get edited!

  $(".figure_edit").change((e) -> 
    console.log( "editor string: "+editor_to_string( $(e.target).closest(".figure_edit") ))) 
  $(".figure_edit").change((e) -> parse_figure_string(editor_to_string( $(e.target).closest(".figure_edit") )))

