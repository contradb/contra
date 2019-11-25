require 'filter_dances'

class Api::V1::DancesController < ApplicationController
  def index
    render json: FilterDances.filter_dances(filter, count: count, offset: offset, dialect: dialect)
  end

  private
  def filter
    ['figure', '*']
  end

  def count
    parseIntWithDefault(params[:count], 10)
  end

  def offset
    parseIntWithDefault(params[:offset], 0)
  end

  def parseIntWithDefault(s, default)
    s =~ /^[0-9]+$/ ? Integer(s) : default
  end
end
