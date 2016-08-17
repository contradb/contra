# coding: utf-8
require 'rails_helper'

RSpec.describe DancesHelper, type: :helper do
  it 'figures render' do
    [['gentlespoons allemande by the right 1½', 'allemande', 'gentlespoons', true, 540, 8],
     ['gentlespoons allemande by the right twice for 10', 'allemande', 'gentlespoons', true, 720, 10],
     ['ladles allemande by the left 1½ around while the gentlespoons orbit counter clockwise ½ around',
      'allemande orbit','ladles',false,540,180,8],
     ['ones balance', 'balance', 'ones', 4],
     ['partners balance and swing', 'balance and swing', 'partners',false, 16], # suspicious...
     ['partners balance and swing', 'balance and swing', 'partners',true, 16], # not suspicious
     ['balance the ring for 6', 'balance the ring', 6],
     ['ladies chain', 'chain', 'ladies', 8],
     ['circle to the left 4 places','circle',true,360,8],
     ['circle to the right 4 places','circle',false,360,8],
     ['circle to the left 3 places', 'circle three places', true, 270, 8],
     ['put your right hand in', 'custom', 'put your right hand in', 8],
     ['put your right hand in for 16', 'custom', 'put your right hand in', 16],
     ['half hey, ladles lead', 'half hey', 'ladles', 8],
     ['hey, gentlespoons lead', 'hey', 'gentlespoons', 16],
     ['hey halfway, ladles lead', 'hey halfway', 'ladles', 8],
     ['long lines', 'long lines', 8],
     ['long lines forward only for 3', 'long lines forward only', 3],
     ['partners long swing','long swing', 'partners', false, 16],
     ['pass through to new neighbors for 4', 'pass through', 4],
     ['balance & petronella', 'petronella', true, 8],
     # ['petronella', 'petronella', false, 8], ambiguous
     ['balance & petronella', 'petronella', true, 8],
     ['progress to new neighbors', 'progress', 0],
     ['neighbors promenade across passing left sides', 'promenade across', 'neighbors', true, 8],
     ['neighbors promenade across passing right sides', 'promenade across', 'neighbors', false, 8],
     ['right left through', 'right left through', 8],
     ['slide left to new neighbors', 'slide', true, 2],
     ['star by the left hands across 4 places','star', false, false, 360, 8],
     ['star by the left 4 places',             'star', false, true, 360, 8],
     ['partners balance & swat the flea', 'swat the flea', 'partners',  true,  false, 8],
     ['neighbors swing', 'swing', 'neighbors', false, 8],
     # below here has issues requiring implementation changes, I think -dm 08-16-2016
     ['neighbors balance and swing', 'swing', 'neighbors', true, 16],
     ['gentlespoons see saw once', 'see saw', 'gentlespoons', false, 360, 8],
     ['petronella', 'petronella', false, 4],
     ['pass through to new neighbors', 'pass through', 2],
     ['pass through to new neighbors for 8', 'pass through', 8],
     ['long lines forward only', 'long lines forward only', 4],
     ['shadows gyre 1½', 'gyre', 'shadows', true, 540, 8],
     ['ladles do si do once around', 'do si do', 'ladles', true, 360, 8],
     ['balance the ring', 'balance the ring', 4],
     ['balance the ring for 8', 'balance the ring', 8], # debatable
     ['partners balance and swing','balance and swing','partners',true,16],
     ['ladles chain', 'chain', 'ladles', 8],
     ['right left through', 'right left through', 8],
     ['partners balance & box the gnat',  'box the gnat',  'partners',  true,  true,  8],
     ['neighbors box the gnat',           'box the gnat',  'neighbors', false, true,  4]
    ].each do |arr|
      render, move, *pvalues = arr
      expect(figure_txt_for(move,*pvalues)).to match(whitespice render)
    end
  end
end

def figure_txt_for(move, *parameter_values)
  figure_txt({'move' => move, 'parameter_values' => parameter_values})
end

# replace every space with one or more whitespace characters
def whitespice(x)
  case x
  when Regexp; x
  when String; /\A#{x.gsub(' ','\s+')}\s*\z/
  else raise 'unexpected type in whitespice'
  end
end
