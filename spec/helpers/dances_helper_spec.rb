# coding: utf-8
require 'rails_helper'

RSpec.describe DancesHelper, type: :helper do

  figure_txt_for = -> move, *parameter_values, dialect {
    JSLibFigure.figure_to_html({'move' => move, 'parameter_values' => parameter_values}, dialect)
  }

  def whitespice(x) 
    case x
    when Regexp; x
    when String;
      quote = Regexp.escape(x).to_s
      /\A\s*#{quote.gsub('\ ','\s+').gsub(/&amp;|&/,'&amp;')}\s*\z/
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
    ['gentlespoons allemande right ½', true, 'allemande', 'gentlespoons', true, 180, 2],
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
    ['ladles chain', true, 'chain', 'ladles', true, 'across', 8],
    ['ladles left-hand chain', false, 'chain', 'ladles', false, 'across', 10],
    ['gentlespoons right-hand chain', false, 'chain', 'gentlespoons', true, 'across', 6],
    ['left diagonal gentlespoons chain', true, 'chain', 'gentlespoons', false, 'left diagonal', 8],
    ['* * *-hand chain', nil, 'chain', '*', '*', '*', '*'],
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
    ['ladles start a half hey - rights in center, lefts on ends', true, 'hey', 'ladles', '', true, 'half', 'across', false, false, false, false, 8],
    ['ladles start a half hey - ____ in center, ____ on ends - ladles ricochet, gentlespoons ricochet', true, 'hey', 'ladles', '', nil, 'half', 'across', true, true, false, false, 8],
    ['ladles start a hey - rights in center, lefts on ends - until ladles meet', false, 'hey', 'ladles', '', true, 'ladles%%1', 'across', false, false, false, false, 16],
    ['neighbors start a full hey - lefts on ends, rights in center - ladles ricochet first time, gentlespoons ricochet second time', true, 'hey', 'neighbors', 'ladles', false, 'full', 'across', true, false, false, true, 16],
    ['partners start a full hey - lefts on ends, rights in center - ladles ricochet first time, gentlespoons ricochet second time', true, 'hey', 'partners', 'ladles', false, 'full', 'across', true, false, false, true, 16],
    ['Error (specify second pass) - partners start a full hey - lefts on ends, rights in center - ____ ricochet first time, others ricochet second time', true, 'hey', 'partners', '', false, 'full', 'across', true, false, false, true, 16],
    ['Error (exactly one pass should be a single pair of dancers) - ladles start a full hey - lefts in center, rights on ends  - ladles ricochet first time, gentlespoons ricochet second time', true, 'hey', 'ladles', 'gentlespoons', false, 'full', 'across', true, false, false, true, 16],
    ['Error (exactly one pass should be a single pair of dancers) - partners start a full hey - lefts on ends, rights in center - ____ ricochet first time, others ricochet second time', true, 'hey', 'partners', 'partners', false, 'full', 'across', true, false, false, true, 16],
    ['gentlespoons start a right diagonal full hey - lefts in center, rights on ends', true, 'hey', 'gentlespoons', '', false, 'full', 'right diagonal', false, false, false, false, 16],
    ['gentlespoons start a right diagonal hey - lefts in center, rights on ends - until gentlespoons meet the second time', false, 'hey', 'gentlespoons', 'partners', false, 'gentlespoons%%2', 'right diagonal', false, false, false, false, 8],
    ['* start a * * hey - * shoulders on ends, * shoulders in center - * maybe ricochet first time, * maybe ricochet first time, * maybe ricochet second time, * maybe ricochet second time', nil, 'hey', '*', '*', '*', '*', '*', '*', '*', '*', '*', '*'],
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
    ['progress', true, 'progress', 0],
    ['progress', nil, 'progress', '*'],
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
    ['slide left along set', true, 'slide along set', true, 2],
    ['slide * along set', nil, 'slide along set', '*', '*'],
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
    ['star left - hands across - 4 places', true, 'star', false, 360, 'hands across', 8],
    ['star right 4 places', true, 'star', true, 360, '', 8],
    ['star right 3 places', true, 'star', true, 270, '', 8],
    ['star left - wrist grip - 5 places', true, 'star', false, 450, 'wrist grip', 10],
    ['star * hand - any grip - * places', nil, 'star', '*', '*', '*', '*'],
    ['partners balance & swat the flea', true, 'swat the flea', 'partners',  true,  false, 8],
    ['* optional balance & swat the flea', nil, 'swat the flea', '*',  '*',  false, '*'],
    ['pass through to a left diagonal ocean wave &amp; balance - ladles by left in the center, neighbors by right on the sides', true, 'form an ocean wave', true, 'left diagonal', true, 'ladles', false, 'neighbors', 8],
    ['form an ocean wave - ladles by right hands and neighbors by left hands', true, 'form an ocean wave', false, 'across', false, 'ladles', true, 'neighbors', 0],
    ['pass through to an ocean wave - ones by left in the center, neighbors by right on the sides', false, 'form an ocean wave', true, 'across', false, 'ones', false, 'neighbors', 2],
    ['form a right diagonal ocean wave & balance - ladles by left hands and partners by right hands', true, 'form an ocean wave', false, 'right diagonal', true, 'ladles', false, 'partners', 4],
    ['* a * ocean wave & maybe balance - * by * hands and * by opposite hands', nil, 'form an ocean wave', '*', '*', '*', '*', '*', '*', '*'],
    ['gentlespoons roll away neighbors with a half sashay', true, 'roll away', 'gentlespoons', 'neighbors', true, 4],
    ['ladles roll away partners', false, 'roll away', 'ladles', 'partners', false, 2], # mabye true, maybe false?
    ['* roll away * maybe with a half sashay', nil, 'roll away', '*', '*', '*', '*'],
    ["balance & Rory O'More right", true, "Rory O'More", 'everyone', true, false, 8],
    ["balance & centers Rory O'More left", true, "Rory O'More", 'centers', true, true, 8],
    ["centers Rory O'More left", true, "Rory O'More", 'centers', false, true, 4],
    ["centers Rory O'More left", false, "Rory O'More", 'centers', false, true, 8],
    ["optional balance & * Rory O'More *", nil, "Rory O'More", '*', '*', '*', '*'],
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
    ['ones half figure 8', true, 'figure 8', 'ones', '', 'first ladle', 0.5, 8],
    ['twos half figure 8 across', false, 'figure 8', 'twos', 'across', 'second ladle', 0.5, 10],
    ['gentlespoons full figure 8 below, first gentlespoon leading', true, 'figure 8', 'gentlespoons', 'below', 'first gentlespoon', 1.0, 16], # change
    ['twos half figure 8 across, second gentlespoon leading', true, 'figure 8', 'twos', 'across', 'second gentlespoon', 0.5, 8],
    ['* * figure 8 *, * leading', nil, 'figure 8', '*', '*', '*', '*', '*'],
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
    ['form long waves - ladles face in, gentlespoons face out', true, 'form long waves', 'ladles', 0],
    ['form long waves - * face in, * face out', nil, 'form long waves', '*', 0],
    ['ladles dance in to a long wave in the center - balance the wave', true, 'form a long wave', 'ladles', true, false, true, 8],
    ['ladles dance out while gentlespoons dance in to a long wave in the center - balance the wave', true, 'form a long wave', 'gentlespoons', true, true, true, 8],
    ['gentlespoons form a long wave in the center', false, 'form a long wave', 'gentlespoons', false, false, false, 4],
    ['ladles dance out & balance', true, 'form a long wave', 'gentlespoons', false, true, true, 8],
    ['* dance out while * dance in to a long wave in the center - *', nil, 'form a long wave', '*', '*', '*', '*', '*'],
    ['revolving door - gentlespoons take left hands and drop off partners on other side', true, 'revolving door', 'gentlespoons', false, 'partners', 8],
    ['revolving door - * take * hands and drop off * on other side', false, 'revolving door', '*', '*', '*', '*'],
    ['dolphin hey - start with ones passing second ladle by left shoulders', true, 'dolphin hey', 'ones', 'second ladle', false, 16],
    ['dolphin hey - start with * passing * by * shoulders', nil, 'dolphin hey', '*', '*', '*', '*'],
   ]

  TESTS.each do |arr|
    render, _good_beats, move, *pvalues = arr
    it "renders #{move} as '#{render}'" do
      e = figure_txt_for.call(move,*pvalues, JSLibFigure.default_dialect)
      expect(e).to match(whitespice(render)), "expected #{e.inspect} to match #{render.inspect}"
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
   ['ravens darcy 1½', 'gyre', 'ladles', true, 540, 8],
   ['ravens swing', 'swing', 'ladles', 'none', 8],
   ['ravens do si do left shoulder once', 'see saw', 'ladles', false, 360, 8],
   ['form a short wavy line - ravens by right hands and neighbors by left hands', 'form an ocean wave', false, 'across', false, 'ladles', true, 'neighbors', 4],
   ['form a left diagonal short wavy line - ravens by right hands and neighbors by left hands', 'form an ocean wave', false, 'left diagonal', false, 'ladles', true, 'neighbors', 4],
   ['pass through to a short wavy line &amp; balance - ravens by right in the center, neighbors by left on the sides', 'form an ocean wave', true, 'across', true, 'ladles', true, 'neighbors', 8],
   ['ravens allemande left 1½ around while the larks orbit clockwise ½ around', 'allemande orbit','ladles',false,540,180,8],
   ['larks arch ravens dive', 'arch & dive','gentlespoons',4],
   ['____ arch others dive', 'arch & dive',nil,4],
   ['<u>ravens</u> <u>almond</u> <u>darcy</u> <u>first lark</u>', 'custom','ladles allemande gyre first gentlespoon', 8],
  ].each do |arr|
    render, move, *pvalues = arr
    it "renders #{move} as '#{render}' with dialect" do
      txt = figure_txt_for.call(move,*pvalues, JSLibFigure.test_dialect)
      expect(txt).to match(whitespice(render)), "expected #{txt.inspect} to equal #{render.inspect}"
    end
  end

  describe "%S in substitutiions" do
    it "renders right shoulder round the way people want" do
      txt = figure_txt_for.call('gyre', 'partners', true, 360, 8, JSLibFigure.shoulder_round_dialect)
      expect(txt).to match('partners right shoulder round once')
    end

    it "doesn't have %S in figure note, does have lingo lines" do
      figure = {'move' => 'gyre', 'parameter_values' => ['partners', true, 360, 8], 'note' => 'this is a gyre'}
      expect(JSLibFigure.figure_to_html(figure,JSLibFigure.shoulder_round_dialect)).to match(whitespice("partners right shoulder round once this is a <u>shoulder round</u>"))
    end
  end
end
