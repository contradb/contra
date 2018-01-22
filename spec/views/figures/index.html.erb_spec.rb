# -*- coding: utf-8 -*-

require 'rails_helper'
require 'move'

RSpec.describe "figures/index", type: :view do
  it 'renders figures in alphabetical substitution order, with links to figures' do
    prefs = JSLibFigure.test_prefs
    assign(:prefs, prefs)
    assign(:move_preferences, JSLibFigure.moves2(prefs))
    assign(:mdtab, Move.mdtab([], prefs))
    render
    expect(rendered).to have_content('allemande orbit almond balance')
    expect(rendered).to have_content('custom darcy do si do')
    expect(rendered).to have_link('allemande orbit', href: '/figures/allemande-orbit')
    expect(rendered).to have_link('almond', href: '/figures/allemande')
    expect(rendered).to have_link('balance', href: '/figures/balance')
    expect(rendered).to have_link('custom', href: '/figures/custom')
    expect(rendered).to have_link('darcy', href: '/figures/gyre')
    expect(rendered).to have_link('do si do', href: '/figures/do-si-do')
  end
end
