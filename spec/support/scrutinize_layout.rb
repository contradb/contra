# to include in features spec put
#   require 'support/scrutinize_layout'
# at top of the file then in a spec call 'scrutinize_layout(page)'
# early and often

def scrutinize_layout(page)
  expect(page).to have_link("ContraDB", href: '/')
  expect(page).to have_link("Figures", href: figures_path)
  expect(page).to have_link("Choreographers", href: choreographers_path)
  expect(page).to have_link("Help")
  expect(page).to have_link("New Dance")
end
