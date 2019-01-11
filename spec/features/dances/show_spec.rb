# coding: utf-8
require 'rails_helper'

describe 'Showing dances' do
  it 'displays fields' do
    user = FactoryGirl.create(:user, moderation: :collaborative)
    dance = FactoryGirl.create(:box_the_gnat_contra, publish: true, user: user)
    visit dance_path dance.id
    expect(page).to have_css('h1', text: dance.title)
    expect(page).to have_content(dance.hook)
    expect(page).to have_link(dance.choreographer.name)
    expect(page).to have_content(dance.start_type)
    expect(page).to have_content(dance.preamble)
    expect(page).to have_text ('neighbors balance & swing')
    expect(page).to have_text ('ladles allemande right 1½')
    expect(page).to have_content(dance.notes)
    expect(page).to have_text('published')
    expect(page).to_not have_text(/collaborative/i)
  end

  it 'displays moderation link' do
    user = FactoryGirl.create(:user, moderation: :collaborative, email: 'sue@yahoo.com')
    dance = FactoryGirl.create(:dance, user: user)
    with_login(admin: true) do
      visit dance_path dance.id
      expect(page).to have_text("Collaborative - moderators may edit or unpublish the dance, emailing sue@yahoo.com the original text")
      expect(page).to have_link('sue@yahoo.com', href: 'mailto:sue@yahoo.com')
    end
  end

  it 'shows appropriate A1B2 and beat labels' do
    dance = FactoryGirl.create(:box_the_gnat_contra)
    visit dance_path dance.id
    expect(page).to have_words('A1 8 neighbors balance & box the gnat 8 partners balance & swat the flea')
    expect(page).to have_words('A2 16 neighbors balance & swing')
    expect(page).to have_words('B1 8 ladles allemande right 1½ 8 partners swing')
    expect(page).to have_words('B2 8 right left through 8 ladles chain')
  end

  it 'respects dialect' do
    expect(JSLibFigure).to receive(:default_dialect).at_least(:once).and_return(JSLibFigure.test_dialect)
    dance = FactoryGirl.create(:box_the_gnat_contra, preamble: "gyre Ladles.Rory O'More-allemande")
    visit dance_path dance.id
    expect(page).to have_text ('ravens almond right 1½')
    expect(page).to_not have_text ('ladles')
    expect(page).to_not have_text ('gentlespoons')
    expect(page).to_not have_text ('allemande')
    expect(page).to have_text('darcy Ravens.sliding doors-almond')
  end

  it 'displays pilcrow' do
    dance = FactoryGirl.build(:box_the_gnat_contra, preamble: "gyre Ladles.Rory O'More-allemande")
    figures = dance.figures.dup
    figures.last['progression'] = 1
    dance.update!(figures: figures)
    visit dance_path(dance)
    expect(page).to have_text('ladles chain ⁋')
  end

  describe 'actions buttons' do
    it 'has only the copy button if we do not own the dance' do
      with_login do |user|
        dance = FactoryGirl.create(:dance)
        visit dance_path dance.id
        expect(page).to have_link('Copy')
        expect(page).to_not have_link('Edit')
        expect(page).to_not have_link('Delete')
      end
    end

    it 'has copy, edit, and delete buttons if we do own the dance' do
      with_login do |user|
        dance = FactoryGirl.create(:dance, user: user)
        visit dance_path dance.id
        expect(page).to have_link('Copy')
        expect(page).to have_link('Edit')
        expect(page).to have_link('Delete')
      end
    end

    it 'has copy, edit, and delete buttons if we are an admin' do
      with_login(admin: true) do |user|
        dance = FactoryGirl.create(:dance)
        visit dance_path dance.id
        expect(page).to have_link('Copy')
        expect(page).to have_link('Edit')
        expect(page).to have_link('Delete')
      end
    end
  end

  it "shows '1st shadow' and '2nd neighbor' when appropriate" do
    dance = FactoryGirl.create(:dance_with_all_shadows_and_neighbors)
    visit dance_path dance.id
    expect(page).to have_content('prev neighbors')
    expect(page).to have_content('2nd neighbors')
    expect(page).to have_content('3rd neighbors')
    expect(page).to have_content('4th neighbors')
    expect(page).to have_content('1st shadows')
    expect(page).to have_content('2nd shadows')
    expect(page).to_not have_content('next neighbors')
    expect(page).to_not have_words('B2 8 shadows swing')
    expect(page).to have_words('B2 8 1st shadows swing')
  end

  it "filters out unapproved html" do
    dance = FactoryGirl.create(:malicious_dance)
    visit dance_path(dance)
    expect(page).to have_content('<b>neighbors</b>')
    expect(page).to have_content('<b>bold</b>')
    expect(page).to_not have_css('b', text: 'neighbors')
    expect(page).to_not have_css('b', text: 'bold')
  end

  it "shows lingo lines for hook, preamble, and dance notes" do
    dance = FactoryGirl.create(:dance, notes: 'box circulate', preamble: "* first gentlespoon\n* second gentlespoon\n\n> four score and seven years", hook: 'women')
    visit dance_path(dance)
    expect(page).to have_css('s', text: 'women')
    expect(page).to have_css('u', text: 'box circulate')
    expect(page).to have_css('u', text: 'first gentlespoon')
    # we had a bug where were were omitting newlines, which was sucking for markdown. Let's try an ordered list!
    expect(page).to have_css('ul', text: /\Afirst gentlespoon second gentlespoon\z/)
    expect(page).to have_css('li', text: /\Afirst gentlespoon\z/)
    expect(page).to have_css('li', text: /\Asecond gentlespoon\z/)
    expect(page).to have_css('blockquote', text: /\Afour score and seven years\z/)
  end

  it "gives helpful feedback to users seeking to access their private dance" do
    user = FactoryGirl.create(:user, password: 'abc%123%ABC')
    dance = FactoryGirl.create(:dance, publish: false, user: user)
    visit dance_path(dance)
    expect(page).to have_content("that dance has not been published - maybe it's yours and you could see it if you logged in?")
    expect(page).to have_current_path(new_user_session_path)
    fill_in('user_email', with: user.email)
    fill_in('user_password', with: user.password)
    click_on('Login')
    expect(page).to have_css('h1', text: dance.title)
    expect(page).to have_current_path(dance_path(dance))
  end

  it "gives helpful feedback to users seeking to access someone else's private dance" do
    dance = FactoryGirl.create(:dance, publish: false)
    with_login do |user|
      visit dance_path(dance)
      expect(page).to have_content("that dance has not been published so you can't see it")
      expect(page).to have_current_path(root_path)
    end
  end
end
