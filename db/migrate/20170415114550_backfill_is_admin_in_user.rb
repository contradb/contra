class BackfillIsAdminInUser < ActiveRecord::Migration
  def up
    User.find_by(id: 1)&.update!(is_admin: true)
  end
  def down
  end
end
