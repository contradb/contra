require 'move'

class PreferencesController < ApplicationController
  def edit
    @preferences_form = PreferencesForm.new
  end

  def update
    @preferences_form = PreferencesForm.new(preferences_form_params)
    if @preferences_form.save
      redirect_to(root_url, notice: 'preferences updated')
    else
      render :edit
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def preferences_form_params
    params.require(:preferences_form).permit(:name)
  end
end
