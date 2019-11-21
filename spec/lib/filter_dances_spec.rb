require 'rails_helper'
require 'filter_dances'


describe FilterDances do
  describe "filter_dances" do
    it 'works with a matchy filter and plenty of dances' do
      dances = 20.times.map { FactoryGirl.create(:dance) }
      filter_results = FilterDances.filter_dances(10, ['figure', '*'], JSLibFigure.default_dialect)
      expect(filter_results.length).to eq(10)
      filter_results.each_with_index do |filter_result, i|
        dance = dances[i]
        expect(filter_result.dance.id).to eq(dance.id)
      end
    end

    it 'works with an unexpectedly unmatchy filter and not enough dances' do
      dance1 = FactoryGirl.create(:dance)
      30.times.each { FactoryGirl.create(:dance_with_zero_figures) }
      dance2 = FactoryGirl.create(:dance)
      dances = [dance1, dance2]
      filter_results = FilterDances.filter_dances(10, ['figure', '*'], JSLibFigure.default_dialect)
      expect(filter_results.length).to eq(2)
      filter_results.each_with_index do |filter_result, i|
        dance = dances[i]
        expect(filter_result.dance.id).to eq(dance.id)
      end
    end

    it 'works with an unexpectedly matchy filter' do
      dances = 30.times.map { FactoryGirl.create(:dance_with_a_swing) }
      filter_results = FilterDances.filter_dances(10, ['figure', 'swing'], JSLibFigure.default_dialect)
      expect(filter_results.length).to eq(10)
      filter_results.each_with_index do |filter_result, i|
        dance = dances[i]
        expect(filter_result.dance.id).to eq(dance.id)
      end
    end
  end

  it 'filter_result_to_json' do
    dance = FactoryGirl.build(:dance)
    result = {
      id: dance.id,
      title: dance.title,
      choreographer_id: dance.choreographer_id,
      choreographer_name: dance.choreographer.name,
      formation: dance.start_type,
      hook: dance.hook,
      user_id: dance.user_id,
      user_name: dance.user.name,
      created_at: dance.created_at.as_json,
      updated_at: dance.updated_at.as_json,
      publish: dance.publish == 'all' && 'everyone',
      matching_figures_html: 'whole dance',
    }.stringify_keys
    expect(FilterDances.filter_result_to_json(dance, 'whole dance')).to eq(result)
  end
end
