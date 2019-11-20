require 'rails_helper'
require 'filter_dances'


describe FilterDances do
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
