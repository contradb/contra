class DancesController < ApplicationController
  before_action :set_dance, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy]
  before_action :authenticate_dance_ownership!, only: [:edit, :update, :destroy]

  # GET /dances
  # GET /dances.json
  def index
    @dances = Dance.all.order "LOWER(title)"
  end

  # GET /dances/1
  # GET /dances/1.json
  def show
  end

  # GET /dances/new
  def new
    @dance = Dance.new
    @dance.title ||= "New Dance" 
  end

  # GET /dances/1/edit
  def edit
  end


  # POST /dances
  # POST /dances.json
  def create
    @dance = Dance.new(dance_params_with_real_choreographer intern_choreographer)
    @dance.user_id = current_user.id
    respond_to do |format|
      if @dance.save
        format.html { redirect_to @dance, notice: 'Dance was successfully created.' }
        format.json { render :show, status: :created, location: @dance }
      else
        format.html { render :new }
        format.json { render json: @dance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dances/1
  # PATCH/PUT /dances/1.json
  def update
    respond_to do |format|
      if @dance.update(dance_params_with_real_choreographer intern_choreographer)
        format.html { redirect_to @dance, notice: 'Dance was successfully updated.' }
        format.json { render :show, status: :ok, location: @dance }
      else
        format.html { render :edit }
        format.json { render json: @dance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dances/1
  # DELETE /dances/1.json
  def destroy
    user = @dance.user
    @dance.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.html do
        coming_from_dance_view = /.*\/dances\/.+/ =~ request.referrer
        url = coming_from_dance_view ? user : request.referrer
        redirect_to url, notice: 'Dance was successfully destroyed.'
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dance
      @dance = Dance.find(params[:id])
    end
    
    def authenticate_dance_ownership!
      authenticate_ownership! @dance.user_id
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dance_params
      params.require(:dance).permit(:title, :choreographer, :choreographer_name, :start_type, :figures_json, :notes, :copy_dance_id)
    end

    def dance_params_with_real_choreographer(c)
      dance_params.except("choreographer_name").merge("choreographer" => c)
    end

    def intern_choreographer
      Choreographer.find_or_create_by( name: dance_params["choreographer_name"] )
    end
end
