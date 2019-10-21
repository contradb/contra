# coding: utf-8
require 'rails_helper'

describe 'Editing dances', js: true do
  it 'displays attributes of an existing dance' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit edit_dance_path dance.id
      expect(page.body).to include(dance.title)
      expect(page.body).to include(dance.choreographer.name)
      expect(page.body).to include(dance.start_type)
      expect(page.body).to include(dance.hook)
      expect(page.body).to include(dance.preamble)
      expect(page.body).to_not match(/Becket/i)
      expect(page).to have_text('neighbors balance & swing')
      expect(page).to have_text('ladles allemande right 1½')
      expect(page.body).to include dance.notes
      expect(page).to have_current_path(edit_dance_path(dance.id))
    end
  end

  it 'editing a dance passes it\'s information through unchanged' do
    with_login do |user|
      choreographer = FactoryGirl.create(:choreographer, name: 'Becky Hill')
      dance1 = FactoryGirl.create(:box_the_gnat_contra, user: user, choreographer: choreographer)
      visit edit_dance_path dance1.id
      click_button 'Save Dance'
      expect(page).to have_content('Dance was successfully updated.')
      dance2 = FactoryGirl.build(:box_the_gnat_contra, user: user, choreographer: choreographer)
      dance1.reload
      expect(current_path).to eq dance_path dance1.id
      %w[title start_type figures hook preamble notes].each do |message|
        expect(dance1.send message).to eql dance2.send message
      end
      expect(dance1.choreographer.name).to eql dance2.choreographer.name
    end
  end

  it 'editing a dance saves form values (except figure editor edits)' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit edit_dance_path dance.id
      fill_in 'dance_title', with: 'Call Me'
      fill_in 'dance[choreographer_name]', with: 'Cary Ravitz'
      fill_in 'dance[start_type]', with: 'Beckett'
      fill_in 'dance[hook]', with: 'wombatty'
      fill_in 'dance[preamble]', with: 'prerambling'
      fill_in 'dance[notes]', with: 'notey'
      choose 'people with link'
      click_button 'Save Dance'
      expect(page).to have_content('Dance was successfully updated.')
      dance.reload

      expect(dance.title).to eq('Call Me')
      expect(dance.choreographer.name).to eq('Cary Ravitz')
      expect(dance.start_type).to eq('Beckett')
      expect(dance.hook).to eq('wombatty')
      expect(dance.preamble).to eq('prerambling')
      expect(dance.notes).to eq('notey')
      expect(dance.publish_link?).to eq(true)
    end
  end

  it 'figure inputs prefill' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)

      # give the swing a note
      figures = dance.figures
      figures[2]['note'] = 'this is a swing'
      dance.update!(figures: figures)

      visit edit_dance_path dance.id
      click_on('figure-2')

      # why 'swing:string' and not 'swing'? Must be some angular thing
      expect(find('#move-2').value).to eq('string:swing')

      figure_value_setters = find_all('.figure-value-setter-div')
      expect(figure_value_setters.length).to eq(5)

      _move, who, prefix, beats, note = figure_value_setters.to_a
      expect(who.find('select').value).to eq('string:neighbors')
      expect(prefix.find("input[value=none]")).to_not be_checked
      expect(prefix.find("input[value=balance]")).to be_checked
      expect(prefix.find("input[value=meltdown]")).to_not be_checked
      expect(beats.find('select').value).to eq('number:16')
      expect(note.find('input').value).to eq('this is a swing')
    end
  end

  it 'figure inputs save' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)

      visit edit_dance_path dance.id
      click_on('figure-6')

      select 'swing', match: :first
      select 'neighbors'
      choose 'meltdown'
      fill_in 'note', with: 'with gusto!'

      click_button 'Save Dance'
      expect(page).to have_content('Dance was successfully updated.')

      dance.reload

      copy = FactoryGirl.build(:box_the_gnat_contra)
      expect(dance.figures.length).to eq(copy.figures.length)
      expect(dance.figures[0,6]).to eq(copy.figures[0,6])
      expect(dance.figures[6]).to eq({'move' => 'swing', 'parameter_values' => ['neighbors', 'meltdown', 16], 'note' => 'with gusto!', 'progression' => 1})
    end
  end

  it "has working A1B2 and beat labels" do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit edit_dance_path dance.id
      expect(page).to have_words('A1 8 neighbors right hand balance & box the gnat 8 partners left hand balance & swat the flea')
      expect(page).to have_words('A2 16 neighbors balance & swing')
      expect(page).to have_words('B1 8 ladles allemande right 1½ 8 partners swing')
      expect(page).to have_words('B2 8 right left through 8 ladles chain')
      expect(page).to_not have_css('.beats-column-danger')
      click_on('neighbors right hand balance & box the gnat')
      select('10')
      expect(page).to have_words('A1 10 neighbors right hand balance & box the gnat')
      expect(page).to have_css('.beats-column-danger', text: '10')
    end
  end

  describe "swing alignment to beats" do
    it "likes aligned swings" do
      with_login do |user|
        dance = FactoryGirl.create(:dance_with_a_swing, user: user)
        visit edit_dance_path dance.id
        expect(page).to have_css('.beats-column', text: 16)
        expect(page).to_not have_css('.beats-column-danger')
      end
    end

    it "warns about non-aligned swings" do
      with_login do |user|
        dance = FactoryGirl.create(:dance_with_a_swing, user: user)
        dance.figures.first['parameter_values'][-1] = 8; # change beats to 8
        dance.update(figures: dance.figures)
        visit edit_dance_path dance.id
        expect(page).to have_css('.beats-column.beats-column-danger', text: 8)
      end
    end
  end

  it 'hey_length chooser works' do
    with_login do |user|
      dance = FactoryGirl.create(:dance_with_a_hey, user: user, hey_length: 'gentlespoons%%2')
      visit edit_dance_path(dance)
      click_link('until gentlespoons meet the second time', exact: false)
      select('gentlespoons meet', exact: true)
      select('ladles meet 2nd time');
      expect(page).to have_text('until ladles meet the second time')
      click_button 'Save Dance'
      expect(page).to have_content('Dance was successfully updated.')
      dance.reload
      expect(JSLibFigure.parameter_values(dance.figures[0])).to include('ladles%%2')
    end
  end

  describe 'dynamic shadow/1st shadow and next neighbor/2nd neighbor behavior' do
    it 'rewrites figure texts' do
      with_login do |user|
        dance = FactoryGirl.create(:dance_with_all_shadows_and_neighbors, user: user)
        visit edit_dance_path dance.id
        expect(page).to_not have_content('next neighbors')
        expect(page).to have_content('2nd neighbors')
        expect(page).to have_words('B2 8 1st shadows swing')
        click_link('3rd neighbors swing')
        select('partners')
        expect(page).to have_content('next neighbors')
        expect(page).to_not have_content('2nd neighbors')
        click_link('2nd shadows swing')
        select('partners')
        expect(page).to_not have_words('B2 8 1st shadows swing')
        expect(page).to have_words('B2 8 shadows swing')
        select('2nd shadows')
        expect(page).to have_words('B2 8 1st shadows swing')
      end
    end

    it 'has dynamic dancer menus' do
      with_login do |user|
        dance = FactoryGirl.create(:dance_with_all_shadows_and_neighbors, user: user)
        visit edit_dance_path dance.id
        click_link('3rd neighbors swing')
        expect(page).to_not have_css('option', text: 'next neighbors')
        expect(page).to have_css('option', text: '2nd neighbors')
        select('partners')
        expect(page).to have_css('option', text: 'next neighbors')
        expect(page).to_not have_css('option', text: '2nd neighbors')
        click_link('2nd shadows swing')
        expect(page).to have_css('option', text: '1st shadows')
        expect(page).to_not have_css('option', text: /\Ashadows\z/)
        select('partners')
        expect(page).to_not have_css('option', text: '1st shadows')
        expect(page).to have_css('option', text: /\Ashadows\z/)
      end
    end
  end

  describe 'dialect text' do
    it 'default terms in a database-fresh dance are translated into dialect in the editor' do
      with_login do |user|
        dialect = JSLibFigure.test_dialect
        dance = FactoryGirl.create(:dance_with_a_custom,
                                   user: user,
                                   custom_text: 'custom allemande gentlespoons custom',
                                   figure_note: 'figure-note allemande figure-note',
                                   preamble: 'preamble allemande preamble',
                                   hook: 'hook allemande hook',
                                   notes: 'dance-notes allemande dance-notes')
        figure = dance.figures.first
        allow_any_instance_of(User).to receive(:dialect).and_return(dialect)
        visit edit_dance_path(dance)

        dance_in_dialect = Dance.find(dance.id).set_text_to_dialect(dialect)
        figure_in_dialect = dance_in_dialect.figures.first

        # custom
        expect(page).to have_words(figure_in_dialect['parameter_values'].first)
        expect(page).to_not have_words(figure['parameter_values'].first)

        # figure note
        expect(page).to have_words(figure_in_dialect['note'])
        expect(page).to_not have_words(figure['note'])

        preamble = page.find('#dance_preamble').value
        expect(preamble).to eq(dance_in_dialect.preamble)
        expect(preamble).to_not have_text(dance.preamble)

        dance_note = page.find('#dance_notes').value
        expect(dance_note).to eq(dance_in_dialect.notes)
        expect(dance_note).to_not have_text(dance.notes)

        hook = page.find('#dance_hook').value
        expect(hook).to eq(dance_in_dialect.hook)
        expect(hook).to_not have_text(dance.hook)
      end
    end


    it 'users type text in their dialect and the db saves in using the default terms' do
      with_login do |user|
        custom_text = 'fluffy'
        dance = FactoryGirl.create(:dance_with_a_custom, custom_text: custom_text, user: user)
        allow_any_instance_of(User).to receive(:dialect).and_return(JSLibFigure.test_dialect)
        visit edit_dance_path(dance)
        expect(page).to have_link(custom_text)
        click_on(custom_text)
        text_in_dialect = 'darcy Ravens.Sliding doors-almond'
        text_in_canon = "gyre Ladles.Rory O'More-allemande"
        fill_in('note', with: text_in_dialect)
        fill_in('custom', with: text_in_dialect)
        fill_in('dance_notes', with: text_in_dialect)
        fill_in('dance_preamble', with: text_in_dialect)
        fill_in('dance_hook', with: text_in_dialect)
        click_on 'Save Dance'
        expect(page).to have_content('Dance was successfully updated.')
        dance = Dance.last
        custom_figure = dance.figures.first
        expect(custom_figure['note']).to eq(text_in_canon)
        expect(custom_figure['parameter_values'].first).to eq(text_in_canon)
        expect(dance.notes).to eq(text_in_canon)
        expect(dance.preamble).to eq(text_in_canon)
        expect(dance.hook).to eq(text_in_canon)
      end
    end

    it 'validation failures do not corrupt dialect text' do
      with_login do |user|
        custom_text = 'custom ladle custom'
        custom_text_in_dialect = 'custom raven custom'
        dance = FactoryGirl.create(:dance_with_a_custom, custom_text: custom_text, user: user)
        allow_any_instance_of(User).to receive(:dialect).and_return(JSLibFigure.test_dialect)
        visit edit_dance_path(dance)
        expect(page).to have_link(custom_text_in_dialect)
        fill_in 'dance_title', with: '' # too short to pass validation
        click_on 'Save Dance'
        expect(page).to_not have_content('Dance was successfully updated.')
        expect(page).to have_link(custom_text_in_dialect)
        expect(page).to_not have_link(custom_text)
      end
    end

    it "filters html out of user input" do
      with_login do |user|
        dance = FactoryGirl.create(:malicious_dance, user: user)
        visit edit_dance_path(dance)
        expect(page).to have_css('button.add-figure') # are we on the editor page?
        expect(page).to_not have_css('b', text: 'neighbors')
        expect(page).to_not have_css('b', text: 'bold')
        expect(page).to have_text(/<b>neighbors<\/b> ?balance & swing this should not be <b>bold<\/b>/)
      end
    end
  end

  describe "lingo lines" do
    it "strikethrough bogusterms and idiom'ed terms" do
      with_login do |user|
        dance = FactoryGirl.create(:dance_with_a_custom, custom_text: 'click this!', user: user)
        allow_any_instance_of(User).to receive(:dialect).and_return(JSLibFigure.test_dialect)
        visit edit_dance_path(dance)
        click_link('click this!')
        custom = "men ramen noodles gentlespoons (men)men- Men men"
        note = "women congresswomen ladles"
        fill_in(:custom, with: custom)
        fill_in(:note, with: note)
        expect(page).to_not have_css('s', text: 'ramen noodles')
        expect(page).to_not have_css('.no-lingo-lines s', text: /\Amen\z/) # don't disable lingo lines in editor, as in #494
        expect(page).to have_css('s', text: /\Amen\z/, count: 4)
        expect(page).to have_css('s', text: /\AMen\z/, count: 1)
        expect(page).to have_css('s', text: 'gentlespoons')
        expect(page).to have_css('s', text: 'women')
        expect(page).to_not have_css('.no-lingo-lines s', text: 'women') # don't disable lingo lines in editor, as in #494
        expect(page).to have_css('s', text: 'ladles')
        expect(page).to_not have_css('s', text: 'congresswomen')
        expect(page).to have_link("#{custom} #{note}")
      end
    end

    it "underline substitutions and non-idiom'ed terms" do
      with_login do |user|
        dance = FactoryGirl.create(:dance_with_a_custom, custom_text: "larks Larks lArks california twirl California twirl Rory O'More rory O'more do si do left shoulder", figure_note: 'ravens swing', user: user)
        allow_any_instance_of(User).to receive(:dialect).and_return(JSLibFigure.test_dialect)
        visit edit_dance_path(dance)
        # custom figure text
        expect(page).to_not have_css('u', text: 'laRKS')
        expect(page).to have_css('u', text: 'larks')
        expect(page).to have_css('u', text: 'Larks')
        expect(page).to have_css('u', text: 'lArks')
        expect(page).to have_css('u', text: "california twirl")
        expect(page).to have_css('u', text: "California twirl")
        expect(page).to_not have_css('u', text: "Rory O'More")
        expect(page).to_not have_css('u', text: "rory o'more")
        expect(page).to have_css('u', text: "sliding doors", count: 2)
        expect(page).to have_css('u', text: 'do si do left shoulder')
        # figure note
        expect(page).to have_css('u', text: 'ravens')
        expect(page).to have_css('u', text: 'swing')
      end
    end
  end
end
