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
end
