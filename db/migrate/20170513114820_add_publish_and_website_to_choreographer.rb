class AddPublishAndWebsiteToChoreographer < ActiveRecord::Migration
  def change
    add_column :choreographers, :publish, :integer
    add_column :choreographers, :website, :string
  end
end
