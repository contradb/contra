class DisallowNullsInChoreographers < ActiveRecord::Migration
  def up
    change_column(:choreographers, :name, :string, default: "", null: false)
    Choreographer.all.each {|d| d.name ||= ""}
  end

  def down
    change_column(:choreographers, :name, :string, {null: true, default: nil})
  end

end
