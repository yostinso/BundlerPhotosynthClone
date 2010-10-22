class ImageController < ApplicationController
  before_filter :require_user
  def upload
    begin
      @photoset = Photoset.find_by_id_and_user_id(params[:photoset], current_user.id)
    rescue
      flash[:warning] = "Couldn't find photoset by ID #{params[:photoset]} for user #{current_user.id}"
      redirect_to user_home_url
    end
    unless @photoset then
      redirect_to user_home_url
      return
    end
  end
  def handle_upload
    begin
      @photoset = Photoset.find_by_id_and_user_id(params[:photoset], current_user.id)
    rescue
      @response = "Couldn't find photoset by ID #{params[:photoset]} for user #{current_user.id}"
    end
    unless @photoset then
      @response = "Couldn't find photoset by ID #{params[:photoset]} for user #{current_user.id}"
    end

    if @photoset then
      @picture = Picture.new(params[:picture])
      @picture.name = @picture.image_file_name
      @picture.user = current_user
      @picture.photoset = @photoset
      if @picture.save then
        @success = true
        @response = ""
        @image_thumb = @picture.image.url(:small_cropped)
      else
        @success = false
        @response = "Failed to upload #{@picture.name}"
      end
    else
      @success = false
    end

    @identity = params[:identity]
    render :layout => false
  end

end
