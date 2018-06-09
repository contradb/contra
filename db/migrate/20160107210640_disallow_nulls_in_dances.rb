class DisallowNullsInDances < ActiveRecord::Migration[4.2]
  def up
    change_column(:dances, :title,      :string, default: "", null: false)
    change_column(:dances, :start_type, :string, default: "", null: false)
    change_column(:dances, :notes,      :text,   default: "", null: false)

    Dance.all.each do |d|
      d.title      ||= ""
      d.start_type ||= ""
      d.notes      ||= ""
    end
  end

  def down
    change_column(:dances, :title,      :string, {null: true, default: nil})
    change_column(:dances, :start_type, :string, {null: true, default: nil})
    change_column(:dances, :notes,      :text,   {null: true, default: nil})
  end
end
