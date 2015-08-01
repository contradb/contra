module DancesHelper
  # IMPORTANT: this constant is manually synced to the equivalent server-side constant
  # in dances.coffee!
  WHO = [:everybody, :partner, :neighbor, :ladles, :gentlespoons, :ones, :twos].freeze;
  BALANCEABLE = {petronella: true, balance_the_ring: true,
    box_the_gnat: true, swat_the_flea: true, california_twirl: true, arizona_twirl: true,
    swing: true, pull_by_left: true, pull_by_right: true,
  }.freeze

  def balance_prefix_ok?(m)
    BALANCEABLE[m]
  end
  COURETSY_TURNABLE = { chain: true, right_left_through: true }.freeze
  def couresy_turn_suffix_ok?(m)
    COURTESY_TURNABLE[m]
  end

  def move_value(m)
    [].find_index m
  end

  # THIS FUNCTION HAS BEEN MOVED TO THE CLIENT SIDE!
  # ITS STILL USED FOR INITIALIZATION ON THE SERVER, BUT IT NEEDS TO GO 
  # TO REMOVE CODE DUPLICATION XXX -dm 07-31-2015
  # the contents of the move menu depend on the value of the who menu.
  # you can't have "Partner Petronella" or "Neighbor Ladle's Chain"
  # this method constructs a swath of html with many valid options
  def move_menu_options(who, default=nil) 
    options = 
      if (:everybody == who)
        [:circle_left, :circle_right, :star_left, :star_right, :petronella,
         :balance_the_ring, :to_ocean_wave, :right_left_through]
      elsif (:partner == who or :neighbor == who)
        [:do_si_do, :see_saw, :allemande_right, :allemande_left,
         :gypsy_right_shoulder, :gypsy_left_shoulder, :swing,
         :pull_by_right, :pull_by_left, 
         :box_the_gnat, :swat_the_flea, :california_twirl, :arizona_twirl]
      elsif (:ladles == who or :gentlespoons == who)
        [:mad_robin, :hey, :half_a_hey, 
        :gypsy_right_shoulder, :gypsy_left_shoulder,
         :chain, :pull_by_right, :pull_by_left,
        :allemande_left_with_orbit, :allemande_right_with_orbit,]
      elsif (:ones == who or :twos == who)
        [:swing]
      else
        error "who parameter to move_menu_options not recognized"
      end
    options.map {|m| content_tag( :option, m.to_s.gsub( "_", " " ), value: move_value(m))}.join(" ")
	  # content_tag( :option, "everybody",    {value: 71, selected: :selected} )+
          # content_tag( :option, "partner",      {value: 72} )+ 
          # content_tag( :option, "neighbor",     {value: 73} )+ 
          # content_tag( :option, "ladles",       {value: 74} )+ 
          # content_tag( :option, "gentlespoons", {value: 75} )+
          # content_tag( :option, "ones",         {value: 76} )+ 
          # content_tag( :option, "twos",         {value: 77} )
  end

end
