require 'dialect_reverser'
require 'email_vault'

class DancesController < ApplicationController
  before_action :set_dance, only: [:destroy, :update, :show, :edit]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :authenticate_dance_writable!, only: [:edit, :update, :destroy]
  before_action :authenticate_dance_readable!, only: [:show]
  before_action :set_dialect_json_for_editing, only: [:new, :create, :edit, :update]

  def index
    @dances = Dance.readable_by(current_user).alphabetical
    respond_to do |format|
      format.html
      format.json do
        render(json: DanceDatatable.new(view_context, user: current_user, figure_query: figure_query_param, dialect: dialect))
      end
    end
  end

  def show
    @dialect = dialect
    @show_validation = @show_moderation = current_user&.admin?
    @tags = Tag.all
    response.set_header('X-Robots-Tag', 'noindex') unless @dance.searchable?
  end

  def new
    copy_dance = params[:copy_dance_id] && Dance.find(params[:copy_dance_id])
    @dance = copy_dance ? Dance.new(copy_dance.attributes.except(%w(id created_at updated_at)).merge(title: "#{copy_dance.title} variation")) : Dance.new(title: 'New Dance')
    @copied_title = copy_dance.title if copy_dance
    @dance.set_text_to_dialect(dialect)
    @choreographer = params[:choreographer_id] ? Choreographer.find(params[:choreographer_id]) : @dance.choreographer
    @admin_email = EmailVault.get(:help_desk, :email)
  end

  def edit
    @dance.set_text_to_dialect(dialect)
    @choreographer = params[:choreographer_id] ? Choreographer.find(params[:choreographer_id]) : @dance.choreographer
    @admin_email = EmailVault.get(:help_desk, :email)
  end

  def create
    @dance = Dance.new(canonical_params(dance_params_with_real_choreographer(intern_choreographer)))
    @dance.user_id = current_user.id
    if @dance.save
      redirect_to @dance, notice: 'Dance was successfully created.'
    else
      @dance.set_text_to_dialect(dialect)
      render :new
    end
  end

  def update
    if @dance.update(canonical_params(dance_params_with_real_choreographer(intern_choreographer)))
      redirect_to @dance, notice: 'Dance was successfully updated.'
    else
      @dance.set_text_to_dialect(dialect)
      render :edit
    end
  end

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
    def set_dance
      @dance = Dance.find(params[:id])
    end

    def set_dialect_json_for_editing
      @dialect_json = JSLibFigure.dialect_with_text_translated(dialect).to_json
    end

    def authenticate_dance_writable!
      current_user&.admin? || authenticate_ownership!(@dance.user_id)
    end

    def authenticate_dance_readable!
      unless @dance.readable?(user: current_user)
        deny_or_login!(deny_notice: "the link to that dance is not shared, so you can't see it", login_notice: "the link to that dance is not shared - maybe it's yours and you could see it if you logged in?")
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dance_params
      dirty_json = params.require(:dance).permit(:title,
                                                 :choreographer,
                                                 :choreographer_name,
                                                 :start_type,
                                                 :hook,
                                                 :preamble,
                                                 :figures_json,
                                                 :notes,
                                                 :copy_dance_id,
                                                 :publish)
      cleaned_json = JSLibFigure.sanitize_json dirty_json[:figures_json]
      dirty_json.merge(figures_json: cleaned_json)
    end

    def figure_query_param
      # params.permit(:draw, :columns, :order, :start, :length, :search, :format, excludeMoves: [], figureQuery: [])
      params.permit!['figureQuery']
    end

    def dance_params_with_real_choreographer(c)
      dance_params.except("choreographer_name").merge("choreographer" => c)
    end

    def intern_choreographer
      Choreographer.find_or_create_by(name: dance_params["choreographer_name"])
    end

    # consider a move to a Dance class method?
  def canonical_params(params)
    dialect_reverser = DialectReverser.new(dialect)
    notes = params[:notes]
    preamble = params[:preamble]
    hook = params[:hook]
    figures = JSON.parse(params[:figures_json])
    figures2 = figures.map do |figure|
      move, parameter_values, note = JSLibFigure.figure_unpack(figure)
      formals = move ? JSLibFigure.formal_parameters(move) : []
      pv2 = parameter_values.each_with_index.map do |parameter_value, i|
        if parameter_value.present? && JSLibFigure.parameter_uses_chooser(formals[i], JSLibFigure.chooser('chooser_text'))
          dialect_reverser.reverse(parameter_value)
        else
          parameter_value
        end
      end
      figure.merge('parameter_values' => pv2).merge(note.present? ? {'note' => dialect_reverser.reverse(note)} : {})
    end
    params.merge(notes: dialect_reverser.reverse(notes),
                 preamble: dialect_reverser.reverse(preamble),
                 hook: dialect_reverser.reverse(hook),
                 figures_json: figures2.to_json)
  end
end
