require 'rails_helper'

RSpec.describe DancesHelper, type: :helper do
  it 'figures render' do
    [['partners balance and swing','balance and swing','partners',true,16],
     ['star by the left hands across 4 places','star', false, false, 360, 8],
     ['star by the left 4 places',             'star', false, true, 360, 8],
     ['ladles chain', 'chain', 'ladles', 8],
     ['right left through', 'right left through', 8],
     ['circle to the left 3 places', 'circle three places', true, 270, 8],
     ['partners balance & box the gnat',  'box the gnat',  'partners',  true,  true,  8],
     ['neighbors box the gnat',           'box the gnat',  'neighbors', false, true,  4],
     ['partners balance & swat the flea', 'swat the flea', 'partners',  true,  false, 8]
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
def whitespice(string)
  /#{string.gsub(' ','\s+')}/
end
