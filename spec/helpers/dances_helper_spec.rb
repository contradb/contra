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
  it '#figure_txt works' do
    ruby_figure_hash = {'move' => 'balance and swing', 
                        'parameter_values' => ['partners',true,16]}
    expect(figure_txt(ruby_figure_hash)).to eq('partners balance and swing')
  end
  context 'star' do
    it 'renders' do
      expect(figure_txt_for('star', false, true, 360, 8)).to match(whitespice 'star by the left 4 places')
    end
    it 'hands across renders' do
      expect(figure_txt_for('star', false, false, 360, 8)).to match(whitespice 'star by the left hands across 4 places')
    end
  end
  it 'ladies chain renders' do
    expect(figure_txt_for('chain', 'ladles', 8)).to match(whitespice 'ladles chain')
  end
end

def figure_txt_for(move, *parameter_values)
  figure_txt({'move' => move, 'parameter_values' => parameter_values})
end

# replace every space with one or more whitespace characters
def whitespice(string)
  /#{string.gsub(' ','\s+')}/
end
