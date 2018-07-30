# coding: utf-8
require 'rails_helper'

describe 'Copying dances', js: true do
  it 'displays attributes of an existing dance' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit new_dance_path copy_dance_id: dance.id
      expect(page).to have_content("Composing a variation of #{dance.title}")
      expect(page.body).to include(dance.title)
      expect(page.body).to include(dance.choreographer.name)
      expect(page.body).to include(dance.start_type)
      expect(page.body).to include(dance.hook)
      expect(page.body).to include(dance.preamble)
      expect(page).to_not match(/Becket/i)
      expect(page).to have_text('neighbors balance & swing')
      expect(page).to have_text('ladles allemande right 1½')
      expect(page.body).to include(dance.preamble)
      expect(page.body).to include(dance.notes)
      expect(page).to have_current_path(new_dance_path copy_dance_id: dance.id)
    end
  end

  it 'editing a dance passes it\'s information through unchanged' do
    with_login do |user|
      dance1 = FactoryGirl.create(:box_the_gnat_contra, user: user)
      visit new_dance_path copy_dance_id: dance1.id
      click_button 'Save Dance'

      expect(page).to have_content("Dance was successfully created")
      dance2 = Dance.last
      expect(current_path).to eq dance_path(dance2)
      %w[start_type figures hook preamble notes].each do |message|
        expect(dance2.send message).to eql dance1.send message
      end
      expect(dance2.title).to eql "#{dance1.title} variation"
      expect(dance2.choreographer.name).to eql dance1.choreographer.name
    end
  end

  it 'applies dialect' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user, preamble: "gyre<allemande>gentlespoons")
      allow_any_instance_of(User).to receive(:dialect).and_return(JSLibFigure.test_dialect)
      visit new_dance_path copy_dance_id: dance.id
      expect(page).to have_text('ravens almond right 1½')
      expect(page.find('#dance_preamble').value).to eq('darcy<almond>larks')
    end
  end

  it 'figure inputs prefill' do
    with_login do |user|
      dance = FactoryGirl.create(:box_the_gnat_contra, user: user)

      # give the swing a note
      figures = dance.figures
      figures[2]['note'] = 'this is a swing'
      dance.update!(figures: figures)

      visit new_dance_path copy_dance_id: dance.id
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
      original = FactoryGirl.create(:box_the_gnat_contra, user: user)
      old_dance_count = Dance.all.length

      visit new_dance_path copy_dance_id: original.id
      click_on('figure-6')

      select 'swing', match: :first
      select 'neighbors'
      choose 'meltdown'
      fill_in 'note', with: 'with gusto!'

      click_button 'Save Dance'

      expect(Dance.all.length).to eq(old_dance_count+1)

      dance = Dance.last

      expect(dance.figures.length).to eq(original.figures.length)
      expect(dance.figures[0,6]).to eq(original.figures[0,6])
      expect(dance.figures[6]).to eq({'move' => 'swing', 'parameter_values' => ['neighbors', 'meltdown', 16], 'note' => 'with gusto!', 'progression' => 1})
    end
  end
end
