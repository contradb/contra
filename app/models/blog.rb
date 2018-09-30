class Blog < ApplicationRecord
  belongs_to :user

  def readable?(user=nil)
    return true if publish?
    user.present? && (user.blogger? || user.admin?)
  end

  def writeable?(user=nil)
    user.present? && (user.blogger? || user.admin?)
  end
end
