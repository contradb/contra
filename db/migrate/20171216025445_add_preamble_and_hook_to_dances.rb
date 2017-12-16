class AddPreambleAndHookToDances < ActiveRecord::Migration[5.0]
  def change
    add_column :dances, :preamble, :text, default: ''
    add_column :dances, :hook, :text, default: ''
  end
end
