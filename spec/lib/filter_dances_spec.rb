# coding: utf-8
require 'rails_helper'
require 'filter_dances'


describe FilterDances do
  let (:dialect) { JSLibFigure.default_dialect }
  let (:user) { FactoryGirl.create(:user) }

  describe "filter_dances" do
    let (:now) { DateTime.now }

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

    it 'honors count and offset' do
      dances = 3.times.map {|i| FactoryGirl.create(:dance, created_at: now - i.hours) }
      filter_results = FilterDances.filter_dances(['figure', '*'], count: 1, offset: 1, dialect: dialect)[:dances]
      expect(filter_results.length).to eq(1)
      expect(filter_results.first['id']).to eq(dances.second.id)
    end

    describe "only finds dances searchable to the provided user" do
      it 'with user unspecified, it displays only public & sketchbook dances' do
        dances = [ :off, :sketchbook, :all ].map {|publish| FactoryGirl.create(:dance, publish: publish)}
        filter_results = FilterDances.filter_dances(['figure', '*'], dialect: dialect)[:dances]
        expect(filter_results.map{|d| d['id']}).to contain_exactly(*dances.drop(1).map(&:id))
      end

      it "with user, displays all that users' dances" do
        dances = [ :off, :sketchbook, :all ].map {|publish| FactoryGirl.create(:dance, publish: publish, user: user)}
        filter_results = FilterDances.filter_dances(['figure', '*'], dialect: dialect, user: user)[:dances]
        expect(filter_results.map{|d| d['id']}).to contain_exactly(*dances.map(&:id))
      end
    end

    it 'checks the numberSearched and numberMatching fields'
  end

  describe "search operators (kinda filter_dances again)" do
    let! (:dances) do
      [:dance, :box_the_gnat_contra, :call_me, :dance_with_zero_figures].map.each_with_index do |name, i|
        FactoryGirl.create(name, hook: "#{i.to_s*10} hook")
      end
    end
    let (:zero) { dances.last }
    let (:dance_titles_without_zero) { dances.map(&:title) - [dances.last.title]}

    def titles(filtered)
      filtered[:dances].map {|json| json['title']}
    end

    describe 'figure' do
      it 'works' do
        filtered = FilterDances.filter_dances(['figure', 'hey'], dialect: dialect)
        expect(titles(filtered)).to eq(['Call Me'])
      end

      it 'wildcard' do
        filtered = FilterDances.filter_dances(['figure', '*'], dialect: dialect)
        expect(titles(filtered)).to contain_exactly(*dance_titles_without_zero)
      end

      it "quotes and spaces work - Rory O'More" do      # something about this figure didn't work -dm 10-15-2017
        rory = FactoryGirl.create(:dance_with_a_rory_o_more);
        dances << rory
        filtered = FilterDances.filter_dances(['figure', "Rory O'More"], dialect: dialect)
        expect(titles(filtered)).to eq([rory.title])
      end

      it 'circle works with an angle' do
        filtered = FilterDances.filter_dances(['figure', 'circle', '*', 360, '*'], dialect: dialect)
        expect(titles(filtered)).to eq(['The Rendevouz'])
      end

      it "'shadow' finds both 'shadow' and '2nd shadow'" do
        first_shadow = FactoryGirl.create(:dance_with_pair, pair: 'shadows')
        second_shadow = FactoryGirl.create(:dance_with_pair, pair: '2nd shadows')
        augmented_dances = dances + [first_shadow, second_shadow]
        filtered = FilterDances.filter_dances(['figure', 'swing', 'shadows', '*', '*'], dialect: dialect)
        expect(titles(filtered)).to contain_exactly(first_shadow.title, second_shadow.title)
      end

      it "'neighbors' finds 'neigbhors', 'prev neighbors', 'next neighbors', '3rd neighbors', and '4th neighbors'" do
        augmented_dances = dances + ['prev neighbors', 'next neighbors', '3rd neighbors', '4th neighbors', 'partners'].map {|n|
          FactoryGirl.create(:dance_with_pair, pair: n)
        }
        partners_should_not_match = augmented_dances.last
        filtered = FilterDances.filter_dances(['figure', 'swing', 'neighbors', '*', '*'], dialect: dialect)
        expect(titles(filtered)).to contain_exactly(*(augmented_dances.map(&:title).sort - [partners_should_not_match.title, zero.title]))
      end
    end

    describe 'formation' do
      # there's some heavier testing of this in features/welcome/index_spec.rb -dm 08-19-2018
      it 'Becket ccw' do
        filtered = FilterDances.filter_dances(['formation', 'Becket ccw'], dialect: dialect)
        expect(titles(filtered)).to eq(['Call Me'])
      end

      it 'improper' do
        filtered = FilterDances.filter_dances(['formation', 'improper'], dialect: dialect)
        expect(titles(filtered)).to contain_exactly(*(dances.map(&:title) - ['Call Me']))
      end

      it 'everything else' do
        FactoryGirl.create(:dance, start_type: 'circle mixer', title: 'wacky')
        filtered = FilterDances.filter_dances(['formation', 'everything else'], dialect: dialect)
        expect(titles(filtered)).to eq(['wacky'])
      end
    end

    it 'progression' do
      filtered = FilterDances.filter_dances(['progression'], dialect: dialect)
      expect(titles(filtered)).to contain_exactly("The Rendevouz", "Box the Gnat Contra", "Call Me")
    end

    it 'progress-with' do
      filtered = FilterDances.filter_dances(['progress-with', ['figure', 'chain']], dialect: dialect)
      expect(titles(filtered)).to contain_exactly("Box the Gnat Contra")
    end

    describe 'and' do
      it 'works' do
        filtered = FilterDances.filter_dances(['and', ['figure', 'circle'], ['figure', 'right left through']], dialect: dialect)
        expect(titles(filtered)).to eq(['Call Me'])
      end

      it 'works with no' do
        filtered = FilterDances.filter_dances(['and', ['no', ['figure', 'chain']], ['figure', 'star']], dialect: dialect)
        expect(titles(filtered)).to eq([])
      end
    end

    it '& works with progression' do
      filtered = FilterDances.filter_dances(['&', ['figure', 'slide along set'], ['progression']], dialect: dialect)
      expect(titles(filtered)).to eq(['The Rendevouz'])
    end

    it 'or' do
      filtered = FilterDances.filter_dances(['or', ['figure', 'circle'], ['figure', 'right left through']], dialect: dialect)
      expect(titles(filtered)).to contain_exactly(*dance_titles_without_zero)
    end

    it 'no' do
      filtered = FilterDances.filter_dances(['no', ['figure', 'hey']], dialect: dialect)
      expect(titles(filtered)).to contain_exactly('The Rendevouz', 'Box the Gnat Contra', zero.title)
    end

    it 'all' do
      dances2 = [:dance_with_a_swing, :dance_with_a_do_si_do].map {|d| FactoryGirl.create(d)}
      filtered = FilterDances.filter_dances(['all', ['figure', 'swing']], dialect: dialect)
      expect(titles(filtered)).to contain_exactly(dances2.first.title, zero.title)
    end

    it 'not' do
      FactoryGirl.create(:dance_with_a_swing)
      filtered = FilterDances.filter_dances(['not', ['figure', 'swing']], dialect: dialect)
      expect(titles(filtered)).to contain_exactly('The Rendevouz', 'Box the Gnat Contra', 'Call Me')
    end

    describe 'then' do
      it 'basically works' do
        filtered = FilterDances.filter_dances(['then', ['figure', 'swing'], ['figure', 'circle']], dialect: dialect)
        expect(titles(filtered)).to contain_exactly('The Rendevouz', 'Call Me')
      end

      it 'works with not' do
        # All the swings in Call Me are immediately followed by either a circle or a right left through.
        filtered = FilterDances.filter_dances(['then', ['figure', 'swing'], ['not', ['or', ['figure', 'circle'], ['figure', 'right left through']]]], dialect: dialect)
        expect(titles(filtered)).to contain_exactly('The Rendevouz', 'Box the Gnat Contra')
      end
    end

    describe 'compare' do
      let (:all_titles) { dances.map(&:title) }

      def filtered_titles(comparison, number)
        titles(FilterDances.filter_dances(['compare', ['constant', 0], comparison, ['constant', number]], dialect: dialect))
      end

      it "0 = 0" do
        expect(filtered_titles('=', 0)).to contain_exactly(*all_titles)
      end

      it "0 > 0" do
        expect(filtered_titles('>', 0)).to eq([])
      end
    end

    describe 'title' do
      it "works case-insensitively" do
        filtered = FilterDances.filter_dances(['user', dances.first.user.name.upcase], dialect: dialect)
        expect(titles(filtered)).to eq([dances.first.title])
      end
    end

    describe 'choreographer' do
      it "works case-insensitively" do
        filtered = FilterDances.filter_dances(['choreographer', dances.first.choreographer.name.upcase], dialect: dialect)
        expect(titles(filtered)).to eq([dances.first.title])
      end
    end

    describe 'user' do
      it "works case-insensitively" do
        filtered = FilterDances.filter_dances(['user', dances.first.user.name.upcase], dialect: dialect)
        expect(titles(filtered)).to eq([dances.first.title])
      end
    end

    describe 'hook' do
      it "works case-insensitively" do
        expect(dances.second.hook).to eq("1111111111 hook")
        filtered = FilterDances.filter_dances(['hook', dances.second.hook.upcase], dialect: dialect)
        expect(titles(filtered)).to eq([dances.second.title])
      end

      it "works with dialect" do
        dances.second.update!(hook: 'so many gyre moves!')
        filtered = FilterDances.filter_dances(['hook', 'darcy'], dialect: JSLibFigure.test_dialect)
        expect(titles(filtered)).to eq([dances.second.title])
      end
    end

    describe 'if' do
      it "only with the then" do
        filter = ['if', ['choreographer', dances.first.choreographer.name],
                  ['figure', 'do si do']]
        filtered = FilterDances.filter_dances(filter, dialect: dialect)
        expect(titles(filtered)).to eq([dances.first.title])
        expect(filtered.dig(:dances, 0, 'matching_figures_html')).to eq('ladles do si do 1½')
      end

      it "with both then and else" do
        filter = ['if', ['choreographer', dances.first.choreographer.name],
                  ['figure', 'do si do'],
                  ['progression']]
        filtered = FilterDances.filter_dances(filter, dialect: dialect)
        titles_with_a_progression = dances.select {|d| d.figures.length > 0}.map(&:title)
        expect(titles(filtered)).to contain_exactly(*titles_with_a_progression)
        expect(filtered[:dances].map {|d| d['matching_figures_html']}).to(
          contain_exactly("ladles do si do 1½", "ladles chain ⁋", "partners balance &amp; swing ⁋")
        )
      end
    end

    describe 'publish' do
      before do
        dances[0].update!(user: user, publish: :all)
        dances[1].update!(user: user, publish: :sketchbook)
        dances[2].update!(user: user, publish: :off)
        dances[3].update!(user: user, publish: :all)
      end

      it "'all' does not return all dances, rather it returns dances with publish: :all" do
        filter = ['publish', 'all']
        filtered = FilterDances.filter_dances(filter, dialect: dialect, user: user)
        expect(titles(filtered)).to contain_exactly(dances[0].title, dances[3].title)
      end

      it "'sketchbook' returns only publish: :sketchbook dances" do
        filter = ['publish', 'sketchbook']
        filtered = FilterDances.filter_dances(filter, dialect: dialect, user: user)
        expect(titles(filtered)).to eq([dances[1].title])
      end

      it "'off' returns only publish: :off dances" do
        filter = ['publish', 'off']
        filtered = FilterDances.filter_dances(filter, dialect: dialect, user: user)
        expect(titles(filtered)).to eq([dances[2].title])
      end
    end

    describe 'by-me' do
      it 'works' do
        dances = [ :off, :sketchbook, :all ].map.each_with_index {|publish, i| FactoryGirl.create(:dance, publish: publish, user: user, title: "Dance-#{i}")}
        dances << FactoryGirl.create(:dance)
        filter = ['by-me']
        filtered = FilterDances.filter_dances(filter, dialect: dialect, user: user)
        expect(titles(filtered)).to contain_exactly(*dances.select {|d| d.user_id == user.id}.map(&:title))
      end
    end
  end

  it 'filter_result_to_json' do
    dance = FactoryGirl.build(:dance, hook: "gentlespoons to the left")
    dialect = JSLibFigure.test_dialect
    hook_in_dialect = JSLibFigure.string_in_dialect(dance.hook, dialect)
    result = {
      id: dance.id,
      title: dance.title,
      choreographer_id: dance.choreographer_id,
      choreographer_name: dance.choreographer.name,
      formation: dance.start_type,
      hook: hook_in_dialect,
      user_id: dance.user_id,
      user_name: dance.user.name,
      created_at: dance.created_at.as_json,
      updated_at: dance.updated_at.as_json,
      publish: (dance.publish == 'all') && 'everywhere',
      matching_figures_html: 'whole dance',
    }.stringify_keys
    expect(FilterDances.filter_result_to_json(dance, 'whole dance', dialect)).to eq(result)
  end
end
