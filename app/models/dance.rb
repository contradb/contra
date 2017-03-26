require 'json'

class Dance < ActiveRecord::Base
  belongs_to :user
  belongs_to :choreographer
  validates :title, length: { in: 3..100 }
  validates :start_type, length: { in: 1..100 }
  accepts_nested_attributes_for :choreographer
  def figures
    JSON.parse figures_json
  end
  # eases form defaulting:
  def choreographer_name () choreographer ? choreographer.name : "" end
  # legacy functions - should not be called anymore:
  def figure1 () JSON.generate (figures[0]||{}); end
  def figure2 () JSON.generate (figures[1]||{}); end
  def figure3 () JSON.generate (figures[2]||{}); end
  def figure4 () JSON.generate (figures[3]||{}); end
  def figure5 () JSON.generate (figures[4]||{}); end
  def figure6 () JSON.generate (figures[5]||{}); end
  def figure7 () JSON.generate (figures[6]||{}); end
  def figure8 () JSON.generate (figures[7]||{}); end

end
