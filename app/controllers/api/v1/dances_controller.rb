require 'filter_dances'

class Api::V1::DancesController < ApplicationController
  def index
    json = FilterDances.filter_dances(Dance.all.limit(10), filter, dialect).map do |filter_result|
      dance_to_search_result(filter_result.dance,
                             filter_result.matching_figures_html)
    end
    render json: json
  end

  private
  def filter
    ['figure', '*']
  end

  def dance_to_search_result(dance, matching_figures_html)
    {
      "id" => dance.id,
      "title" => dance.title,
      "choreographer_id" => dance.choreographer_id,
      "choreographer_name" => dance.choreographer.name,
      "formation" => dance.start_type,
      "hook" => dance.hook,
      "user_id" => dance.user_id,
      "user_name" => dance.user.name,
      "created_at" => dance.created_at.as_json,
      "updated_at" => dance.updated_at.as_json,
      "publish" => dance_publish_cell(dance.publish),
      "matching_figures_html" => matching_figures_html
    }
  end

  def dance_publish_cell(enum_value)
    case enum_value.to_s
    when 'all'
      'everyone'
    when 'link'
      'link'
    when 'off'
      'myself'
    else
      raise 'Fell through enum case statement'
    end
  end
end
