require 'filter_dances'
require 'sort_parser'

class Api::V1::DancesController < ApplicationController
  # small security risk: dialetcs are snoopable with this
  skip_before_action :verify_authenticity_token

  def index
    render json:FilterDances.filter_dances(filter,
                                           count: count,
                                           offset: offset,
                                           dialect: dialect,
                                           sort_by: sort_by)
  end

  private
  def filter
    ['figure', '*']
  end

  def sort_by
    params[:sort_by] || ""
  end

  def count
    default_integer_param(:count, 10)
  end

  def offset
    default_integer_param(:offset, 0)
  end

  def default_integer_param(s, default)
    p = params[s]
    case p
    when Integer                # path in production
      p
    when String                 # path for request specs, because: frustration!
      Integer(p)
    else
      default
    end
  end
end
