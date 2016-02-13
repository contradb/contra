

# to include in features spec put
#   require 'support/shared_examples_for_layout'
# at top of the file then call 'assert_working_menubar page'
# early and often


def scrutinize_layout (page)
  expect(page).to have_link("ContraDB")
  expect(page).to have_link("Dances")
  expect(page).to have_link("Choreographers")
  expect(page).to have_link("Users")
end

