class AddNewsEmailAndModeratorEmailToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :news_email, :boolean, default: true, null: false
    add_column :users, :moderation, :integer, default: 0, null: false
  end
end
