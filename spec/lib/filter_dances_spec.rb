require 'rails_helper'
require 'filter_dances'


describe FilterDances do
  describe "filter_dances" do
    let (:now) { DateTime.now }
    let (:dialect) { JSLibFigure.default_dialect }
    it 'works with a matchy filter and plenty of dances' do
      dances = 20.times.map {|i| FactoryGirl.create(:dance, created_at: now - i.hours) }
      filter_results = FilterDances.filter_dances(['figure', '*'], count: 10, dialect: dialect)[:dances]
      expect(filter_results.length).to eq(10)
      filter_results.each_with_index do |filter_result, i|
        dance = dances[i]
        expect(filter_result['id']).to eq(dance.id)
      end
    end

    it 'works with an unexpectedly unmatchy filter and not enough dances' do
      dance1 = FactoryGirl.create(:dance)
      30.times.each {|i| FactoryGirl.create(:dance_with_zero_figures, created_at: now - i.hours) }
      dance2 = FactoryGirl.create(:dance, created_at: now - 100.hours)
      dances = [dance1, dance2]
      filter_results = FilterDances.filter_dances(['figure', '*'], count: 10, dialect: dialect)[:dances]
      expect(filter_results.length).to eq(2)
      filter_results.each_with_index do |filter_result, i|
        dance = dances[i]
        expect(filter_result['id']).to eq(dance.id)
      end
    end

    it 'works with an unexpectedly matchy filter' do
      dances = 30.times.map do |i|
        t = now - i.hours
        FactoryGirl.create(:dance_with_a_swing, created_at: t, updated_at: t)
      end
      filter_results = FilterDances.filter_dances(['figure', 'swing'], count: 10, dialect: dialect)[:dances]
      expect(filter_results.length).to eq(10)
      filter_results.each_with_index do |filter_result, i|
        dance = dances[i]
        expect(filter_result['id']).to eq(dance.id)
      end
    end

    it 'returns dances in most-recently-created order' do
      random = Random.new(1000) # repeatable seed.
      dances = 10.times.map do |i|
        t = now - random.rand(100).hours
        FactoryGirl.create(:dance, created_at: t)
      end
      filter_results = FilterDances.filter_dances(['figure', '*'], count: 10, dialect: dialect)[:dances]
      dances_sorted = dances.sort_by(&:created_at).reverse
      filter_results.each_with_index do |filter_result, i|
        dance = dances_sorted[i]
        expect(filter_result['id']).to eq(dance.id)
      end
    end

    it 'honors count and offset'
    it 'checks the numberSearched and numberMatching fields'
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
