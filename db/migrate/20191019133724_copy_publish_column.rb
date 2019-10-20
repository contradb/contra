class CopyPublishColumn < ActiveRecord::Migration[5.1]
  def up
    Dance.all.each do |dance|
      dance.update!(publish: dance.boolean_publish ? :all : :off)
    end
  end
end
