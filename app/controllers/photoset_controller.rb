class PhotosetController < ApplicationController
  def new
    @photoset = Photoset.new(:user => current_user)
  end

  def create
    @photoset = Photoset.new(params[:photoset])
    @photoset.user = current_user # Nice try
    if @photoset.save
      flash[:notice] = "Photoset created"
      redirect_to :controller => :image, :action => :upload, :photoset => @photoset.id
    else
      render :action => :new
    end
  end

  def destroy
    if @photoset.user == current_user then
      @photoset.destroy
      flash[:notice] = "Photoset removed"
    else
      flash[:warning] = "Photoset not removed"
    end
      redirect_to user_home_url
  end

end
