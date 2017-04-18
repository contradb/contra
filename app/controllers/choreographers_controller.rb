class ChoreographersController < ApplicationController

  #Amar advises dispensing with this bit, and I agree. Just fold the
  #assignment into the individual methods.
  before_action :set_choreographer, only: [:show, :edit, :update, :destroy]

  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy]
  before_action :authenticate_administrator!, only: [:edit, :update, :destroy]

  # GET /choreographers
  # GET /choreographers.json
  def index
    @choreographers = Choreographer.all.order "LOWER(name)"
    @show_admin_actions = current_user&.is_admin
  end

  # GET /choreographers/1
  # GET /choreographers/1.json
  def show
    @dances = @choreographer.dances.readable_by(current_user).alphabetical
  end

  # GET /choreographers/new
  def new
    @choreographer = Choreographer.new
  end

  # GET /choreographers/1/edit
  def edit
  end

  # POST /choreographers
  # POST /choreographers.json
  def create
    @choreographer = Choreographer.new(choreographer_params)

    respond_to do |format|
      if @choreographer.save
        format.html { redirect_to @choreographer, notice: 'Choreographer was successfully created.' }
        format.json { render :show, status: :created, location: @choreographer }
      else
        format.html { render :new }
        format.json { render json: @choreographer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /choreographers/1
  # PATCH/PUT /choreographers/1.json
  def update
    respond_to do |format|
      if @choreographer.update(choreographer_params)
        format.html { redirect_to @choreographer, notice: 'Choreographer was successfully updated.' }
        format.json { render :show, status: :ok, location: @choreographer }
      else
        format.html { render :edit }
        format.json { render json: @choreographer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /choreographers/1
  # DELETE /choreographers/1.json
  def destroy
    @choreographer.destroy
    respond_to do |format|
      format.html { redirect_to choreographers_url, notice: 'Choreographer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_choreographer
      @choreographer = Choreographer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def choreographer_params
      params.require(:choreographer).permit(:name)
    end
end
