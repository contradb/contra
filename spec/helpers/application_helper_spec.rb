require 'rails_helper'

describe DancesHelper, type: :helper do
  describe 'conditional_classes' do
    it { expect(helper.conditional_classes(test: true, thens: 'extra', always: 'base')).to eq('base extra') }
    it { expect(helper.conditional_classes(test: false, thens: 'extra', always: 'base')).to eq('base') }
    it { expect(helper.conditional_classes(test: true, thens: 'extra', elses: 'else', always: 'base')).to eq('base extra') }
    it { expect(helper.conditional_classes(test: false, thens: 'extra', elses: 'else', always: 'base')).to eq('base else') }
    it { expect(helper.conditional_classes(test: true, thens: 'extra')).to eq('extra') }
    it { expect(helper.conditional_classes(test: false, thens: 'extra')).to eq('') }
  end
end
