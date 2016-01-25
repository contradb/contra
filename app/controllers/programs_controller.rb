class ProgramsController < ApplicationController
  before_action :set_program, only: [:show, :edit, :update, :destroy]

  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy]
  before_action :authenticate_program_ownership!, only: [:edit, :update, :destroy]

  # GET /programs
  # GET /programs.json
  def index
    @programs = Program.all
  end

  # GET /programs/1
  # GET /programs/1.json
  def show
  end

  # GET /programs/new
  def new
    @program = Program.new
    3.times {|i| @program.activities.build(index: i)}
  end

  # GET /programs/1/edit
  def edit
  end

  # POST /programs
  # POST /programs.json
  def create
    @program = Program.new(program_params)
    @program.user_id = current_user.id
    @program.activities.each_with_index {|a,i| a.index = i}
    respond_to do |format|
      if @program.save
        format.html { redirect_to @program, notice: 'Program was successfully created.' }
        format.json { render :show, status: :created, location: @program }
      else
        format.html { render :new }
        format.json { render json: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /programs/1
  # PATCH/PUT /programs/1.json
  def update
    respond_to do |format|

      # wipe out all associated activities and start fresh
      @program.activities.destroy(@program.activities)

      # install 'index' attribute into pp hash
      pp = program_params.deep_dup
      ppaa = pp["activities_attributes"]
      i = 0
      while ppaa[i.to_s] do
        ppaa[i.to_s]["index"] = i
        i += 1
      end

      # pp hash is deltas to @program, try to save it...
      if @program.update(pp)
        format.html { redirect_to @program, notice: 'Program was successfully updated.' }
        format.json { render :show, status: :ok, location: @program }
      else
        format.html { render :edit }
        format.json { render json: @program.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /programs/1
  # DELETE /programs/1.json
  def destroy
    user = @program.user
    @program.destroy
    respond_to do |format|
      coming_from_program_view = /.*\/programs\/.+/ =~ request.referrer
      url = coming_from_program_view ? user : request.referrer
      format.html {redirect_to url, notice: 'Program was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_program
      @program = Program.find(params[:id])
    end

    def authenticate_program_ownership!
      authenticate_ownership! @program.user_id
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def program_params
      params.require(:program).permit(:title, :copy_program_id, activities_attributes: [:text, :dance_id])
    end

    # helper function that generates all the natural numbers. 
    def naturals
      Enumerator.new do |yielder|
        i = 0
        loop do
          yielder.yield i
          i += 1
        end
      end
    end
end

