class CreateDuts < ActiveRecord::Migration[5.1]
  def change
    create_table :duts do |t|
      t.references :dance, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.references :tag, foreign_key: true, null: false
      t.timestamps
    end
    add_index :duts, [:dance_id, :user_id, :tag_id], unique: true
  end
end
