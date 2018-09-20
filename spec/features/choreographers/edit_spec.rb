require 'rails_helper'

describe 'Editing choreographer' do
  describe 'auth' do
    let (:choreographer) {FactoryGirl.create(:choreographer)}
    # These feature specs were mostly used to tdd out the new
    # definition of authenticate_administrator!. If you delete them,
    # make sure that's still tested.
    it 'denied for regular user' do
      with_login do
        visit(edit_choreographer_path(choreographer))
        expect(page).to have_content("Only an admin can do this")
        expect(page).to have_current_path(root_path)
      end
    end

    it 'denies and prompts for login with no login' do
      visit(edit_choreographer_path(choreographer))
      expect(page).to have_content("Only an admin can do this")
      expect(page).to have_current_path(new_user_session_path)
    end

    it 'allows admin through' do
      with_login(admin: true) do
        visit(edit_choreographer_path(choreographer))
        expect(page).to have_css('h1', text: "Choreographer #{choreographer.name}")
        expect(page).to have_current_path(edit_choreographer_path(choreographer))
      end
    end
  end
end
