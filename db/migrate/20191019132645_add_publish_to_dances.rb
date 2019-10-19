class AddPublishToDances < ActiveRecord::Migration[5.1]
  def change
    add_column :dances, :publish, :integer, null: false, default: 2 # :all
  end
end
