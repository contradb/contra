require 'rails_helper'
require 'login_helper'

describe 'figures show' do
  let (:box) { FactoryGirl.create(:box_the_gnat_contra) }
  let (:call) { FactoryGirl.create(:call_me) }

  describe 'usage tab' do
    it 'without dialect' do
      box
      visit figure_path('swing')
      expect(page).to have_title("Swing | Figure | Contra")
      expect(page).to have_css("h1", text: 'Swing')
      expect(page).to have_content('related figures: meltdown swing')
      expect(page).to have_content('formal parameters: who, bal, beats')
      # 'examples' table should have two swings for Box the Gnat
      expect(page).to have_content("#{box.title} neighbors balance & swing partners swing")
    end

    it 'with dialect' do
      with_login do |user|
        allow_any_instance_of(User).to receive(:dialect).and_return(JSLibFigure.test_dialect)
        box
        visit figure_path('allemande')
        expect(page).to have_title("Almond | Figure | Contra")
        expect(page).to have_css("h1", text: 'Almond')
        expect(page).to have_content("#{box.title} ravens almond")
      end
    end

    it 'with dialect 2' do
      with_login do |user|
        allow_any_instance_of(User).to receive(:dialect).and_return(JSLibFigure.test_dialect)
        box
        visit figure_path('see saw')
        expect(page).to have_title("Do Si Do Left Shoulder | Figure | Contra")
        expect(page).to have_css("h1", text: 'Do Si Do Left Shoulder')
      end
    end

    it 'aliases' do
      see_saw = FactoryGirl.create(:dance_with_a_see_saw)
      do_si_do = FactoryGirl.create(:dance_with_a_do_si_do)
      visit figure_path('see-saw')
      expect(page).to have_css("#with-examples a", text: see_saw.title)
      expect(page).to_not have_css("#with-examples a", text: do_si_do.title)
    end
  end
  it 'without tab' do
    box
    call
    visit figure_path('star')
    expect(page).to have_css("#without", text: box.title)
    expect(page).to_not have_css("#without", text: call.title)
  end

  describe 'with-figure tab' do
    it 'works' do
      box
      call
      visit figure_path('star')
      call.aliases.each do |move|
        expect(page).to have_css("#with-figure", text: "#{move} #{call.title}") unless 'star' == move
      end
      expect(page).to_not have_css("#with-figure", text: box.title)
    end

    it 'works with dialect'
  end

  describe 'beside-figure tab' do
    it 'works' do
      box
      visit figure_path('swing')
      expect(page).to have_css("#moves-preceding", text: "swat the flea #{box.title}")
      expect(page).to have_css("#moves-preceding", text: "allemande #{box.title}")
      expect(page).to_not have_css("#moves-preceding", text: "right left through #{box.title}")
      expect(page).to have_css("#moves-following", text: "allemande #{box.title}")
      expect(page).to have_css("#moves-following", text: "right left through #{box.title}")
      expect(page).to_not have_css("#moves-following", text: "swat the flea #{box.title}")
    end

    it 'works with dialect'
  end
end
