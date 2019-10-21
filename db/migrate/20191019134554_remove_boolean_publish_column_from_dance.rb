class RemoveBooleanPublishColumnFromDance < ActiveRecord::Migration[5.1]
  def change
    remove_column :dances, :boolean_publish, :boolean
  end
end
