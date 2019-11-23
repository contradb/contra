require 'filter_dances'

class Api::V1::DancesController < ApplicationController
  def index
    render json: FilterDances.filter_dances(filter, count: 10, offset: 0, dialect: dialect)
  end

  private
  def filter
    ['figure', '*']
  end
end
