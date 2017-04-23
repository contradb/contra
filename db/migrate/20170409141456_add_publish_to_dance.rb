class AddPublishToDance < ActiveRecord::Migration
  def change
    add_column :dances, :publish, :boolean, default: true, null: false
  end
end
