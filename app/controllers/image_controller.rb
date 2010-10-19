class ImageController < ApplicationController
  def upload
  end
  def handle_upload
    @identity = params[:identity]
    @success = true;
    @response = "Done."
    render :layout => false
  end

end
