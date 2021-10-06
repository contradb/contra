require 'filter_dances'
require 'sort_parser'

class Api::V1::ProgramsController < ApplicationController
  # todo: verify user is logged in to their own account, 
  # maybe look at non-api controllers for how to do that. 

  # small security risk: dialetcs are snoopable with this
  skip_before_action :verify_authenticity_token
  
  before_action :authenticate_user!
  def index
    # p "___________"
    # p programs
    # p "___________"
    # p programs[0]['title']
    p program_parameters
    Program.create(program_parameters)
    render json: {}
    # Program.create({title: "hello world", user_id: 1, activities_attributes: [{index: 1, text: "first waltz"}]})
  end

  # permitted = params.permit(person: [ :name, { pets: :name } ])
  # permitted.permitted?                    # => true
  # permitted[:person][:name]               # => "Francesco"
  # permitted[:person][:age]                # => nil
  # permitted[:person][:pets][0][:name]     # => "Purplish"
  # permitted[:person][:pets][0][:category] # => nil
  
  def program_parameters
    progs = params.require(:programs)
    prog = progs[0]
    activities = prog["activities"].map {|a| {dance_id: a.dig('dance', 'id'), text: a["text"], index: a["index"]}}
    return {title: prog["title"], user_id: current_user.id , activities_attributes: activities}
    puts "never get here"
    thing = progs[0].permit(:title, activities: [:id, :dance, :text, :index, :interimDraggableId ])
    activities = thing['activities']
    return {title: thing.title, activities: activities.map {|activity| {dance_id: activity.dance_id, id: activity.id, text: activity.text, index: activity.index}}}
    # params[:programs] || []
  end
end
