class CreateBlogs < ActiveRecord::Migration[5.1]
  def change
    create_table :blogs do |t|
      t.text :title
      t.text :body
      t.references :user, foreign_key: true
      t.boolean :publish, default: false, null: false
      t.timestamps
    end
  end
end
