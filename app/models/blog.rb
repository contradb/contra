class Blog < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  validates :body, presence: true

  def writeable?(user=nil)
    self.class.writeable?(user)
  end

  def self.writeable?(user=nil)
    user.present? && (user.blogger? || user.admin?)
  end

  def readable?(user=nil)
    return true if publish?
    user.present? && (user.blogger? || user.admin?)
  end

  def body_html
    ApplicationHelper::renderMarkdownHtmlOk(body || '')
  end
end
