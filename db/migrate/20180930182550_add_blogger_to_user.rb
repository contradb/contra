class AddBloggerToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :blogger, :boolean, default: false, null: false
  end
end
