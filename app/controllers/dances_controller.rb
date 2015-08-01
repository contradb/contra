class DancesController < ApplicationController
  before_action :set_dance, only: [:show, :edit, :update, :destroy]

  # GET /dances
  # GET /dances.json
  def index
    @dances = Dance.all
  end

  # GET /dances/1
  # GET /dances/1.json
  def show
  end

  # GET /dances/new
  def new
    @dance = Dance.new
  end

  # GET /dances/1/edit
  def edit
  end

  # POST /dances
  # POST /dances.json
  def create
    @dance = Dance.new(dance_params)

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
      if @dance.update(dance_params)
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
    @dance.destroy
    respond_to do |format|
      format.html { redirect_to dances_url, notice: 'Dance was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dance
      @dance = Dance.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dance_params
      params.require(:dance).permit(:title, :choreographer_id, :start_type, :figure1, :figure2, :figure3, :figure4, :figure5, :figure6, :figure7, :figure8, :notes)
    end
end
