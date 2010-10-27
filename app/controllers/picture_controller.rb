class PictureController < ApplicationController
  layout false
  before_filter :require_user
  def destroy
    # Don't return anything, we want the 404
    begin
      @picture = Picture.find_by_user_id_and_id(current_user.id, params[:id])
    rescue
    end
    raise ActiveRecord::RecordNotFound.new("Couldn't find picture for user #{current_user.id} with ID #{params[:id]}") if @picture.nil?
    @picture.destroy
    render :text => "success"
  end

end
