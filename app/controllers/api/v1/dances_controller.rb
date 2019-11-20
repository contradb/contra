require 'filter_dances'

class Api::V1::DancesController < ApplicationController
  def index
    json = FilterDances.filter_dances_to_json(10, filter, dialect)
    render json: json
  end

  private
  def filter
    ['figure', '*']
  end
end
