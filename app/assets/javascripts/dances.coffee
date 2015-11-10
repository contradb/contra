# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


# IMPORTANT: this constant is manually synced to the equivalent server-side constant
# in dances_helper.rb!
# WHOs elements must be composed of letters, digits, or underscores
WHO = ["", "everybody", "partner", "neighbor", "ladles", "gentlespoons", "ones", "twos", "centers"]

# This is not actually used, I'm pretty sure, so stop maintaining it after October 2015
# # If adding here, be sure to add one or more "who" reactors in move_menu_options too,
# # and there'll probably be a ruby-side version of this list that needs to be manually synced
# # as well. 
# # MOVES elements must be composed of letters, digits, or underscores
# MOVES = ["circle_left", "circle_right", "star_left", "star_right", "petronella", "balance_the_ring", "to_ocean_wave", "right_left_through", "swing", "do_si_do", "see_saw", "allemande_right", "allemande_left", "gypsy_right_shoulder", "gypsy_left_shoulder", "pull_by_right", "pull_by_left", "box_the_gnat", "swat_the_flea", "california_twirl", "arizona_twirl", "chain", "mad_robin", 
#   #"allemande_left_with_orbit", "allemande_right_with_orbit",
#   "hey", "half_a_hey", "balance", "figure_8", "long_lines", "slide_right_rory_o_moore", "slide_left_rory_o_moore", "promenade_across", "star_promenade", "butterfly_whirl", "gypsy_star_gents_backup", "gypsy_star_ladies_backup", "roll_away", "cross_trails", "down_the_hall", "up_the_hall", "contra_corners", "custom"] 

# returns values [type, default]
move_parameter = (move) ->
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
# NOTE: this function is duplicated rubyside in dances_helper.rb. Sync them.
move_cares_about_rotations = (move) ->
    switch move
      when "do_si_do", "see_saw", "allemande_right", "allemande_left", "gypsy_right_shoulder", "gypsy_left_shoulder" then true
      else false

# NOTE: this function is duplicated rubyside in dances_helper.rb. Sync them.
move_cares_about_places = (move) ->
    switch move
      when "circle_left", "circle_right", "star_left", "star_right" then true
      else false

move_cares_about_balance = (move) ->
    switch move
      when "petronella", "swing", "pull_by_right", "pull_by_left", "box_the_gnat", "swat_the_flea", "california_twirl", "arizona_twirl", "slide_right_rory_o_moore", "slide_left_rory_o_moore", "custom" then true
      else false


move_menu_options = (who) ->
  labels = switch who
             # if adding to this list, be sure to add the move to the MOVES array above,
             # and follow instructions there. 
             when "" then []
             when "everybody" then [
               "circle_left", "circle_right", "star_left", "star_right", "long_lines", 
               "petronella", "balance_the_ring", "to_ocean_wave", 
               "slide_right_rory_o_moore", "slide_left_rory_o_moore", # as in Rory'o'Moore
               "right_left_through"]
             when "partner", "neighbor" then [ "swing",
               "do_si_do", "see_saw", "allemande_right", "allemande_left",
               "gypsy_right_shoulder", "gypsy_left_shoulder",
               "pull_by_right", "pull_by_left", 
               "box_the_gnat", "swat_the_flea", "california_twirl", "arizona_twirl",
               "promenade_across",
               "balance"]
             when "ladles", "gentlespoons" then [ "chain",
               "do_si_do", "see_saw", "allemande_right", "allemande_left",
               "gypsy_right_shoulder", "gypsy_left_shoulder",
               "chain", "pull_by_right", "pull_by_left",
               # "allemande_left_with_orbit", "allemande_right_with_orbit",
               "mad_robin", "hey", "half_a_hey",
               "balance"]
             when "ones", "twos" then ["swing","figure_8"]
             when "centers" then ["swing",
                          "allemande_right", "allemande_left",
                          "slide_right_rory_o_moore", "slide_left_rory_o_moore"]
  labels.push("custom") unless who=="" # custom is almost always available
  ("<option>"+label+"</option>" for label in labels).join(" ")

figure_editor_get_figure = ($editor) ->
  who       = $editor.find(".who_edit").val()
  move      = $editor.find(".move_edit").val()
  beats     = $editor.find(".beat_edit").val()
  balance   = $editor.find(".balance_edit").prop("checked")
  rotations = $editor.find(".rotations_edit").val()
  places    = $editor.find(".places_edit").val()
  notes    = $editor.find(".notes_edit").val()
  o = new Object();
  o["who"] = who
  o["move"] = move
  o["beats"] = parseInt beats
  o["balance"] = true if balance
  if move_cares_about_places(move)    then o["degrees"] = parseInt places
  if move_cares_about_rotations(move) then o["degrees"] = parseInt rotations
  if notes then o["notes"] = notes
  console.log("figure_editor_get_figure(#{$editor}) => #{JSON.stringify(o)}")
  return o
 
figure_editor_set_figure = ($editor, figure) ->
  $who = $editor.find(".who_edit")
  $who.val(figure["who"])
  manage_who_change($who[0])
  $move = $editor.find(".move_edit")
  $move.val(figure["move"])
  manage_move_change($move[0])
  $editor.find(".beat_edit").val(figure["beats"].toString())
  $editor.find(".balance_edit").prop("checked",true) if figure["balance"]
  degrees = if figure["degrees"] then figure["degrees"].toString() else null 
  $editor.find(".rotations_edit").val(degrees) if degrees && move_cares_about_rotations(figure["move"])
  $editor.find(".places_edit").val(degrees)  if degrees && move_cares_about_places(figure["move"])
  $editor.find(".notes_edit").val(figure["notes"])
  return $editor
  

find_buddy_editor = ($editor, selector) ->
  $($editor.closest(".figure_edit")).find( selector )

# takes DOM who editor 
# builds move menu
manage_who_change = (who) ->
  $move = find_buddy_editor(who, ".move_edit")
  $move.html(move_menu_options(who.value))
  manage_move_change($move[0])

# takes DOM move editor 
manage_move_change = (move) ->
    $move = $(move)
    find_buddy_editor($move,".rotations_edit").toggle( move_cares_about_rotations( $move.val() ) )
    find_buddy_editor($move,".rotations_edit").val(move_parameter($move.val())[1])
    find_buddy_editor($move,".places_edit").toggle   ( move_cares_about_places(    $move.val() ) )
    find_buddy_editor($move,".places_edit").val(move_parameter($move.val())[1])
    be = find_buddy_editor($move,".balance_edit")
    be.prop("disabled", !move_cares_about_balance($move.val()))
    be.prop("checked",  be.prop("checked") && move_cares_about_balance($move.val()))


initialize_figure_editor = ( e, i ) ->
  $e = $(e) # the figure editor
  id = trailing_number_from_string( $e.attr('id') )
  $f = $e.closest("form").find(".figure_hidden_#{id}") # the text form
  s  = $f.val()
  o  = if s then jQuery.parseJSON(s) else new Object()
  console.log("initialize_figure_editor \##{id} #{$f} to #{s}")
  $who = find_buddy_editor($e,".who_edit")
  $who.val(o["who"] || "")
  manage_who_change( $who[0] )
  find_buddy_editor($e,".balance_edit").prop("checked", o["balance"]) if o["balance"]
  manage_move_change(
    find_buddy_editor($e,".move_edit").val(o["move"] || "circle_left"))
  find_buddy_editor($e,".rotations_edit").val(o["degrees"] || "360") if o["degrees"]
  find_buddy_editor($e,".places_edit").val(o["degrees"] || "360") if o["degrees"]
  # many Bothans died to bring us this expression:
  beats = if "beats" of o then o["beats"] else 8 
  find_buddy_editor($e,".beat_edit").val(beats)
  find_buddy_editor($e,".notes_edit").val(o["notes"]) if o["notes"]
  return e

trailing_number_from_string = (s) ->
  digs = /\d+$/.exec(s)
  if digs then parseInt(digs) else 0 


# after a change the figure editor, adjust the hidden form
# to hold the JSON representation of that figure. 
sync_figure_editor = (dom_ed) ->
  $fig_ed = $(dom_ed).closest(".figure_edit")
  json = JSON.stringify( figure_editor_get_figure( $fig_ed ))
  id = trailing_number_from_string( $fig_ed.attr('id') )
  console.log("sync_figure_editor #{id} gets json #{json}");
  $form = $fig_ed.closest("form").find(".figure_hidden_#{id}")
  $form.val(json)

$ ->
  console.log("initializing figure editors ... even if we're not editing any figures - say because we're not in the dance editor.")
  $(".who_edit").change((e) -> manage_who_change e.target)
  $(".move_edit").change((e) -> manage_move_change e.target)
  $(".figure_edit").each((i) -> initialize_figure_editor( this, i ))
  # cool! change() gets called on contailers when children get edited!
  $(".figure_edit").change((e) -> sync_figure_editor(e.target))
  

