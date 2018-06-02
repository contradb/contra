class AddPublishToDance < ActiveRecord::Migration[4.2]
  def change
    add_column :dances, :publish, :boolean, default: true, null: false
  end
end
