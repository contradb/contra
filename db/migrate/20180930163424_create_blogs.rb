class CreateBlogs < ActiveRecord::Migration[5.1]
  def change
    create_table :blogs do |t|
      t.text :title
      t.text :body
      t.references :user, foreign_key: true
      t.boolean :publish, default: false, null: false
      t.boolean :publish, default: false, null: false
      t.datetime :sort_at, null: false
      t.timestamps
    end
  end
end
