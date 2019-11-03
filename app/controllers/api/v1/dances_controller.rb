class Api::V1::DancesController < ApplicationController
  def index
    render json: Dance.all.limit(10).map(&:to_search_result)
  end
end
