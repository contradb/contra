class BackfillIsAdminInUser < ActiveRecord::Migration
  def up
    User.find_by(id: 1)&.update!(admin: true)
  end
  def down
  end
end
