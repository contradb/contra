require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the DancesHelper. For example:
#
# describe DancesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe DancesHelper, type: :helper do
  it 'figures render' do
    [['partners balance and swing','balance and swing','partners',true,16],
     ['star by the left hands across 4 places','star', false, false, 360, 8],
     ['star by the left 4 places',             'star', false, true, 360, 8],
     ['ladles chain', 'chain', 'ladles', 8],
     ['right left through', 'right left through', 8],
     ['partners balance & box the gnat', 'box the gnat', 'partners', true, 8],
     ['neighbors box the gnat', 'box the gnat', 'neighbors', false, 4]
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
