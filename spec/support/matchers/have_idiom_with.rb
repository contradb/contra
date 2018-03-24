require 'rspec/expectations'

# this has a bug, somehow, see:
#       expect(page).to_not have_field('gentlespoons-substitution', with: 'brontosauruses') # js wait, masking mysterious bug
#       expect(page).to_not have_idiom(dancer_idiom)
RSpec::Matchers.define :have_idiom_with do |term, substitution|
  match do |page|
    subid = JSLibFigure.slugify_move(term) + '-substitution'
    have_field(subid, with: substitution).matches?(page)
  end
end
