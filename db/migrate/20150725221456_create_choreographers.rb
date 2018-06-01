class CreateChoreographers < ActiveRecord::Migration[4.2]
  def change
    create_table :choreographers do |t|
      t.string :name

      t.timestamps null: false

      t.index :name, unique: true
    end
  end
end
