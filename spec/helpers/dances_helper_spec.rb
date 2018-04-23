# coding: utf-8
require 'rails_helper'

RSpec.describe DancesHelper, type: :helper do

  figure_txt_for = -> move, *parameter_values, dialect {
    JSLibFigure.figureToString({'move' => move, 'parameter_values' => parameter_values}, dialect)
  }

  def whitespice(x) 
    case x
    when Regexp; x
    when String;
      quote = Regexp.escape(x).to_s
      /\A\s*#{quote.gsub('\ ','\s+')}\s*\z/
    else raise 'unexpected type in whitespice'
    end
  end

  TESTS =
   [['____ allemande ____ once', true, 'allemande', nil, nil, 360, 8],
    ['partners balance & swing', true, 'swing', 'partners','balance', 16],
    ['neighbors balance & swing', true, 'swing', 'neighbors', 'balance', 16],
    ['neighbors swing', true, 'swing', 'neighbors', 'none', 8],
    ['neighbors balance & swing', false, 'swing', 'neighbors', 'balance', 8],
    ['partners long swing', true, 'swing', 'partners', 'none', 16],
    ['partners swing', false, 'swing', 'partners', 'none', 20],
    ['partners balance & swing', false, 'swing', 'partners', 'balance', 20],
    ['* * swing', nil, 'swing', '*','*', '*'],
    ['gentlespoons allemande right 1½', true, 'allemande', 'gentlespoons', true, 540, 8],
    ['gentlespoons allemande right twice', false, 'allemande', 'gentlespoons', true, 720, 10],
    ['gentlespoons allemande right twice', true, 'allemande', 'gentlespoons', true, 720, 12],
    ['* allemande * hand *', nil, 'allemande', '*', '*', '*', '*'],
    ['ladles allemande left 1½ around while the gentlespoons orbit clockwise ½ around', true, 'allemande orbit','ladles',false,540,180,8],
    ["* allemande * hand * around while the * orbit * * around", nil, 'allemande orbit','*','*','*','*','*'],
    ['balance', true, 'balance', 'everyone', 4],
    ['ones balance', true, 'balance', 'ones', 4],
    ['ones balance', false, 'balance', 'ones', 8],
    ['* balance', nil, 'balance', '*', '*'],
    ['balance the ring', true, 'balance the ring', 4],
    ['balance the ring', false, 'balance the ring', 6],
    ['balance the ring', false, 'balance the ring', 8],
    ['balance the ring', nil, 'balance the ring', '*'],
    ['ladies chain', true, 'chain', 'ladies', 'across', 8],
    ['left diagonal gentlespoons chain', true, 'chain', 'gentlespoons', 'left diagonal', 8],
    ['* * chain', nil, 'chain', '*', '*', '*'],
    ['circle left 4 places', true, 'circle', true, 360, 8],
    ['circle right 4 places', true, 'circle', false, 360, 8],
    ['circle right 5 places', true, 'circle', false, 450, 10],
    ['circle right 4 places', false, 'circle', false, 360, 10],
    ['circle left 3 places', true, 'circle', true, 270, 8],
    ['circle * * places', nil, 'circle', '*', '*', '*'],
    ['put your right hand in', true, 'custom', 'put your right hand in', 17],
    ['custom', true, 'custom', '  ', 8],
    ['custom', nil, 'custom', '*', '*'],
    ['custom', nil, 'custom', ' ', '*'],
    ['put your right hand in', nil, 'custom', 'put your right hand in', '*'],
    ['half hey, ladles lead', true, 'hey', 'ladles', 0.5, 'across', 8],
    ['hey, gentlespoons lead', true, 'hey', 'gentlespoons', 1.0, 'across', 16],
    ['right diagonal hey, gentlespoons lead', true, 'hey', 'gentlespoons', 1.0, 'right diagonal', 16],
    ['* * hey, * lead', nil, 'hey', '*', '*', '*', '*'],
    ['long lines forward & back', true, 'long lines', true, 8],
    ['long lines forward', false, 'long lines', false, 3],
    ['long lines forward', true, 'long lines', false, 4],
    ['long lines forward & maybe back', nil, 'long lines', '*', '*'],
    ['balance & petronella', true, 'petronella', true, 8],
    ['cross trails - partners along the set right shoulders, neighbors across the set left shoulders', false, 'cross trails', 'partners', 'along', true, 'neighbors', 8],
    ['cross trails - neighbors across the set right shoulders, partners along the set left shoulders', true, 'cross trails', 'neighbors', 'across', true, 'partners', 4],
    ['cross trails - * * the set * shoulders, * * the set * shoulders', nil, 'cross trails', '*', '*', '*', '*', '*'],
    # ['petronella', 'petronella', false, 8], ambiguous
    ['optional balance & petronella', nil, 'petronella', '*', '*'],
    ['progress to new neighbors', true, 'progress', 0],
    ['progress to new neighbors', nil, 'progress', '*'],
    ['pull by right', true, 'pull by direction', false, 'along', true, 2],
    ['pull by left', false, 'pull by direction', false, 'along', false, 4],
    ['pull by right across the set', true, 'pull by direction', false, 'across', true, 2],
    ['pull by left across the set', true, 'pull by direction', false, 'across', false, 2],
    ['balance & pull by right', true, 'pull by direction', true, 'along', true, 8],
    ['balance & pull by left', false, 'pull by direction', true, 'along', false, 6],
    ['balance & pull by right across the set', true, 'pull by direction', true, 'across', true, 8],
    ['balance & pull by left across the set', false, 'pull by direction', true, 'across', false, 6],
    ['pull by left across the set', false, 'pull by direction', false, 'across', false, 4],
    ['pull by left diagonal', false, 'pull by direction', false, 'left diagonal', false, 4],
    ['pull by left hand right diagonal', false, 'pull by direction', false, 'right diagonal', false, 4],
    ['pull by right hand left diagonal', false, 'pull by direction', false, 'left diagonal', true, 4],
    ['pull by right diagonal', false, 'pull by direction', false, 'right diagonal', true, 4],
    ['pull by left hand right diagonal', false, 'pull by direction', false, 'right diagonal', false, 4],
    ['optional balance & pull by * hand *', nil, 'pull by direction', '*', '*', '*', '*'],
    ['gentlespoons pull by right', true, 'pull by dancers', 'gentlespoons', false, true, 2],
    ['ladles pull by left', false, 'pull by dancers', 'ladles', false, false, 4],
    ['ones balance & pull by left', false, 'pull by dancers', 'ones', true, false, 6],
    ['neighbors balance & pull by left', true, 'pull by dancers', 'neighbors', true, false, 8],
    ['* optional balance & pull by * hand', nil, 'pull by dancers', '*', '*', '*', '*'],
    ['neighbors promenade left diagonal on the left', true, 'promenade', 'neighbors', 'left diagonal', true, 8],
    ['neighbors promenade', true, 'promenade', 'neighbors', 'across', false, 8],
    ['neighbors promenade along the set on the right', true, 'promenade', 'neighbors', 'along', false, 8],
    ['neighbors promenade along the set on the left', true, 'promenade', 'neighbors', 'along', true, 8],
    ['* promenade * on the *', nil, 'promenade', '*', '*', '*', '*'],
    ['right left through', true, 'right left through', 'across', 8],
    ['left diagonal right left through', true, 'right left through', 'left diagonal', 8],
    ['* right left through', nil, 'right left through', '*', '*'],
    ['slide left along set to new neighbors', true, 'slide along set', true, 2],
    ['slide * along set to new neighbors', nil, 'slide along set', '*', '*'],
    ['star promenade left ½', true, 'star promenade', 'gentlespoons', false, 180, 4], # prefer: "scoop up partners for star promenade"
    ['star promenade left ¾', true, 'star promenade', 'gentlespoons', false, 270, 6],
    ['ladles star promenade right ½', false, 'star promenade', 'ladles', true, 180, 8],
    ['* star promenade * hand *', nil, 'star promenade', '*', '*', '*', '*'],
    ['butterfly whirl', true, 'butterfly whirl', 4],
    ['butterfly whirl', false, 'butterfly whirl', 8],
    ['butterfly whirl', nil, 'butterfly whirl', '*'],
    ['down the hall', true, 'down the hall', 'everyone', 'all', 'forward', '', 8],
    ['ones down the center', true, 'down the hall', 'ones', 'center', 'forward', '', 8],
    ['down the hall and turn as a couple', true, 'down the hall', 'everyone', 'all', 'forward', 'turn-couple', 8],
    ['down the hall and turn alone', true, 'down the hall', 'everyone', 'all', 'forward', 'turn-alone', 8],
    ['down the hall backward', true, 'down the hall', 'everyone', 'all', 'backward', '', 8],
    ['up the hall and bend into a ring', true, 'up the hall', 'everyone', 'all', 'forward', 'circle', 8],
    ['up the hall forward and backward', true, 'up the hall', 'everyone', 'all', 'forward and backward', '', 8],
    ['twos up the outsides', true, 'up the hall', 'twos', 'outsides', 'forward', '', 8],
    ['* up the * * and end however', nil, 'up the hall', '*', '*', '*', '*', '*'],
    ['mad robin, gentlespoons in front', true, 'mad robin', 'gentlespoons', 360, 6], # gonna be cool with 6
    ['mad robin, gentlespoons in front', true, 'mad robin', 'gentlespoons', 360, 8], # gonna be cool with 8
    ['mad robin twice around, ladles in front', true, 'mad robin', 'ladles', 720, 12],
    ['mad robin * around, * in front', nil, 'mad robin', '*', '*', '*'],
    ['star left 4 places, hands across', true, 'star', false, 360, 'hands across', 8],
    ['star right 4 places', true, 'star', true, 360, '', 8],
    ['star right 3 places', true, 'star', true, 270, '', 8],
    ['star left 5 places, wrist grip', true, 'star', false, 450, 'wrist grip', 10],
    ['star * hand * places, any grip', nil, 'star', '*', '*', '*', '*'],
    ['partners balance & swat the flea', true, 'swat the flea', 'partners',  true,  false, 8],
    ['* optional balance & swat the flea', nil, 'swat the flea', '*',  '*',  false, '*'],
    ['to ocean wave', true, 'ocean wave', false, 4],
    ['to ocean wave & balance the wave', false, 'ocean wave', true, 4],
    ['to ocean wave & balance the wave', true, 'ocean wave', true, 8],
    ['to ocean wave', false, 'ocean wave', false, 8],
    ['to ocean wave & maybe balance the wave', nil, 'ocean wave', '*', '*'],
    ['gentlespoons roll away neighbors with a half sashay', true, 'roll away', 'gentlespoons', 'neighbors', true, 4],
    ['ladles roll away partners', false, 'roll away', 'ladles', 'partners', false, 2], # mabye true, maybe false?
    ['* roll away * maybe with a half sashay', nil, 'roll away', '*', '*', '*', '*'],
    ["balance & Rory O'Moore right", true, "Rory O'Moore", 'everyone', true, false, 8],
    ["balance & centers Rory O'Moore left", true, "Rory O'Moore", 'centers', true, true, 8],
    ["centers Rory O'Moore left", true, "Rory O'Moore", 'centers', false, true, 4],
    ["centers Rory O'Moore left", false, "Rory O'Moore", 'centers', false, true, 8],
    ["optional balance & * Rory O'Moore *", nil, "Rory O'Moore", '*', '*', '*', '*'],
    ['pass through', false, 'pass through', 'along', true, 4],
    ['pass through', true, 'pass through', 'along', true, 2],
    ['pass through left shoulders across the set', true, 'pass through', 'across', false, 2],
    ['pass through * shoulders *', nil, 'pass through', '*', '*', '*'],
    ['gentlespoons give & take partners', true, 'give & take', 'gentlespoons', 'partners', true, 8],
    ['gentlespoons give & take partners', false, 'give & take', 'gentlespoons', 'partners', true, 4],
    ['ladles take neighbors', true, 'give & take', 'ladles', 'neighbors', false, 4],
    ['ladles take neighbors', false, 'give & take', 'ladles', 'neighbors', false, 8],
    ['* give? & take *', nil, 'give & take', '*', '*', '*', '*'],
    ['partners meltdown swing', true, 'meltdown swing', 'partners', 'meltdown', 16],
    ['neighbors meltdown swing', false, 'meltdown swing', 'neighbors', 'meltdown', 12],
    ['* meltdown swing', nil, 'meltdown swing', '*', 'meltdown', '*'],
    ['ones gate twos to face out of the set', true, 'gate', 'ones', 'twos', 'out', 8],
    ['* gate * to face any direction', nil, 'gate', '*', '*', '*', '*'],
    ['gentlespoons see saw once', true, 'see saw', 'gentlespoons', false, 360, 8],
    ['* see saw *', nil, 'see saw', '*', false, '*', '*'],
    ['petronella', true, 'petronella', false, 4],
    ['neighbors box the gnat', true, 'box the gnat',  'neighbors', false, true,  4],
    ['partners balance & box the gnat',  true, 'box the gnat',  'partners',  true,  true,  8],
    ['* optional balance & box the gnat', nil, 'box the gnat',  '*',  '*',  '*',  '*'],
    ['ladles do si do once', true, 'do si do', 'ladles', true, 360, 8],
    ['ladles do si do twice', false, 'do si do', 'ladles', true, 720, 8],
    ['neighbors do si do twice', true, 'do si do', 'neighbors', true, 720, 16],
    ['* do si do *', nil, 'do si do', '*', '*', '*', '*'],
    ['shadows gyre 1½', true, 'gyre', 'shadows', true, 540, 8],
    ['neighbors gyre ¾', false, 'gyre', 'neighbors', true, 270, 8],
    ['ones gyre left shoulders 1½', true, 'gyre', 'ones', false, 540, 8],
    ['* gyre *', nil, 'gyre', '*', '*', '*', '*'],
    ['facing star clockwise 3 places with gentlespoons putting their left hands in and backing up',
    false, 'facing star', 'gentlespoons', true, 270, 10],
    ['facing star clockwise 4 places with ladles putting their left hands in and backing up', false, 'facing star', 'ladles', true, 360, 8],
    ['facing star counter-clockwise 3 places with ladles putting their right hands in and backing up', true, 'facing star', 'ladles', false, 270, 8],
    ['facing star * * places with * putting their * hands in and backing up', nil, 'facing star', '*', '*', '*', '*'],
    ['gentlespoons pass by right shoulders', true, 'pass by', 'gentlespoons', true, 2],
    ['neighbors pass by right shoulders', true, 'pass by', 'neighbors', true, 2],
    ['* pass by * shoulders', nil, 'pass by', '*', '*', '*'],
    ['ones figure 8', true, 'figure 8', 'ones', 'first ladle', 0.5, 8],
    ['gentlespoons full figure 8, first gentlespoon leading', true, 'figure 8', 'gentlespoons', 'first gentlespoon', 1.0, 16], # change
    ['twos figure 8, gentlespoon leading', true, 'figure 8', 'twos', 'second gentlespoon', 0.5, 8],
    ['* * figure 8, * leading', nil, 'figure 8', '*', '*', '*', '*'],
    ['zig left zag right into a ring', true, 'zig zag', 'partners', true, 'ring', 6],
    ['neighbors zig left zag right into a ring', false, 'zig zag', 'neighbors', true, 'ring', 8],
    ['zig left zag right, trailing two catching hands', true, 'zig zag', 'partners', true, 'allemande', 6],
    ['zig right zag left, trailing two catching hands', false, 'zig zag', 'partners', false, 'allemande', 8],
    ['* zig * zag * ending however', nil, 'zig zag', '*', '*', '*', '*'],
    ['half poussette - ladles pull neighbors back then left', true, 'poussette', 0.5, 'ladles', 'neighbors', true, 8],
    ['half poussette - twos pull ones back then right', true, 'poussette', 0.5, 'twos', 'ones', false, 6],
    ['full poussette - twos pull ones back then right', true, 'poussette', 1.0, 'twos', 'ones', false, 12],
    ['full poussette - twos pull ones back then right', true, 'poussette', 1.0, 'twos', 'ones', false, 16],
    ['* poussette - * pull * back then *', nil, 'poussette', '*', '*', '*', '*', '*'],
    ['square through two - partners balance & pull by right, then neighbors pull by left', true, 'square through', 'partners', 'neighbors', true, true, 180, 8],
    ['square through three - same roles pull by right, then partners pull by left, then same roles pull by right', true, 'square through', 'same roles', 'partners', false, true, 270, 6],
    ['square through three - same roles pull by right, then partners pull by left, then same roles pull by right', false, 'square through', 'same roles', 'partners', false, true, 270, 8],
    ['square through four - shadows balance & pull by right, then neighbors pull by left, then repeat', true, 'square through', 'shadows', 'neighbors', true, true, 360, 16],
    ['square through * - * optional balance & pull by * hand, then * pull by *, yadda yadda yadda', nil, 'square through', '*', '*', '*', '*', '*', '*'],
    ['balance & box circulate - gentlespoons cross while ladles loop right', true, 'box circulate', 'gentlespoons', true, true, 8],
    ['balance & box circulate - gentlespoons cross while ladles loop right', false, 'box circulate', 'gentlespoons', true, true, 4],
    ['box circulate - ones cross while twos loop left', false, 'box circulate', 'ones', false, false, 2],
    ['box circulate - ones cross while twos loop left', true, 'box circulate', 'ones', false, false, 4],
    ['optional balance & box circulate - * cross while * loop * hand', nil, 'box circulate', '*', '*', '*', '*'],
    ['partners California twirl', true, 'California twirl', 'partners', 4],
    ['neighbors California twirl', false, 'California twirl', 'neighbors', 2],
    ['* California twirl', nil, 'California twirl', '*', '*'],
    ['ones contra corners', true, 'contra corners', 'ones', '', 16],
    ['twos contra corners left hands', false, 'contra corners', 'twos', 'left hands', 10],
    ['* contra corners *', nil, 'contra corners', '*', '*', '*'],
    ['slice left and straight back', true, 'slice', true, 'couple', 'straight', 8],
    ['slice left', true, 'slice', true, 'couple', 'none', 4],
    ['slice right one dancer and diagonal back', false, 'slice', false, 'dancer', 'diagonal', 10],
    ['slice * one * and *', nil, 'slice', '*', '*', '*', '*'],
    ['turn alone', true, 'turn alone', 'everyone', '', 4],
    ['ladles turn alone over the right shoulder', true, 'turn alone', 'ladles', 'over the right shoulder', 4],
    ['ladles turn alone to a new partner', true, 'turn alone', 'ladles', 'to a new partner', 4],
    ['ladles turn alone face out', true, 'turn alone', 'ladles', 'face out', 2],
    ['* turn alone', nil, 'turn alone', '*', '', '*'],
    ['ones arch twos dive', true, 'arch & dive','ones',4],
    ['* arch * dive', nil, 'arch & dive','*','*'],
   ]

  TESTS.each do |arr|
    render, _good_beats, move, *pvalues = arr
    it "renders #{move} as '#{render}'" do
      expect(figure_txt_for.call(move,*pvalues, JSLibFigure.default_dialect)).to match(whitespice(render))
    end
  end

  TESTS.each do |arr|
    _render, good_beats, move, *pvalues = arr
    figure_text = figure_txt_for.call(move,*pvalues, JSLibFigure.default_dialect)
    unless nil == good_beats
      it "#{figure_text} #{pvalues.inspect} should have #{good_beats ? 'good' : 'questionable'} beats" do
        figure = {'move' => move, 'parameter_values' => pvalues}
        expect(JSLibFigure.good_beats?(figure)).to eq(good_beats)
      end
    end
  end

  [['ravens almond right 1½', 'allemande', 'ladles', true, 540, 8],
   ['ravens darcy right shoulders 1½', 'gyre', 'ladles', true, 540, 8],
   ['ravens swing', 'swing', 'ladles', 'none', 8],
   ['ravens do si do left shoulder once', 'see saw', 'ladles', false, 360, 8],
   ['mush into short wavy lines', 'ocean wave', false, 4],
   ['ravens allemande left 1½ around while the larks orbit clockwise ½ around', 'allemande orbit','ladles',false,540,180,8],
   ['larks arch ravens dive', 'arch & dive','gentlespoons',4],
   ['____ arch others dive', 'arch & dive',nil,4],
   ['ravens almond darcy first lark', 'custom','ladles allemande gyre first gentlespoon', 8],
  ].each do |arr|
    render, move, *pvalues = arr
    it "renders #{move} as '#{render}' with dialect" do
      expect(figure_txt_for.call(move,*pvalues, JSLibFigure.test_dialect)).to match(whitespice(render))
    end
  end
end
