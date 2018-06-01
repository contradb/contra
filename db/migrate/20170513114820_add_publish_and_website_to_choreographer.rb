class AddPublishAndWebsiteToChoreographer < ActiveRecord::Migration[4.2]
  def change
    add_column :choreographers, :publish, :integer
    add_column :choreographers, :website, :string
  end
end
