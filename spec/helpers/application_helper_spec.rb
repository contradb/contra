require 'rails_helper'

describe DancesHelper, type: :helper do
  describe 'conditional_classes' do
    it do
      expect(helper.conditional_classes(test: true, thens: 'extra', always: 'base')).to eq('base extra')
    end

    it do
      expect(helper.conditional_classes(test: false, thens: 'extra', always: 'base')).to eq('base')
    end

    it do
      expect(helper.conditional_classes(test: true, thens: 'extra', elses: 'else', always: 'base')).to eq('base extra')
    end

    it do
      expect(helper.conditional_classes(test: false, thens: 'extra', elses: 'else', always: 'base')).to eq('base else')
    end

    it do
      expect(helper.conditional_classes(test: true, thens: 'extra')).to eq('extra')
    end

    it do
      expect(helper.conditional_classes(test: false, thens: 'extra')).to eq('')
    end
  end
end
