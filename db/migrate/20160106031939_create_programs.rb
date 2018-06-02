class CreatePrograms < ActiveRecord::Migration[4.2]
  def change
    create_table :programs do |t|
      t.string :title, null: false, limit: 100
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
