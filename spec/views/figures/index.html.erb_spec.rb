# -*- coding: utf-8 -*-

require 'rails_helper'
require 'move'

RSpec.describe "figures/index", type: :view do
  it 'renders figures in alphabetical substitution order, with links to figures' do
    dialect = JSLibFigure.test_dialect
    assign(:dialect, dialect)
    assign(:move_terms_and_substitutions, JSLibFigure.move_terms_and_substitutions(dialect))
    assign(:mdtab, Move.mdtab([], dialect))
    render
    expect(rendered).to have_content('allemande orbit almond arch & dive balance')
    expect(rendered).to have_content('custom darcy do si do')
    expect(rendered).to have_link('allemande orbit', href: '/figures/allemande-orbit')
    expect(rendered).to have_link('almond', href: '/figures/allemande')
    expect(rendered).to have_link('balance', href: '/figures/balance')
    expect(rendered).to have_link('arch & dive', href: '/figures/arch-and-dive')
    expect(rendered).to have_link('custom', href: '/figures/custom')
    expect(rendered).to have_link('darcy', href: '/figures/gyre')
    expect(rendered).to have_link('do si do', href: '/figures/do-si-do')
  end
end
