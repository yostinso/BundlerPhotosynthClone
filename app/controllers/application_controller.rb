class ApplicationController < ActionController::Base
  protect_from_forgery

  def self.bundler_config
    ApplicationController.new.bundler_config
  end
  def bundler_config
    conf = YAML::load(File.read(File.join(Rails.root, "config", "bundler.yml")))[Rails.env]
  end
  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  def require_user
    unless current_user
      store_location_for_login
      redirect_to new_user_session_url
      return false
    end
  end
  def require_no_user
    if current_user
      store_location_for_login
      redirect_to_back_or_default welcome_index
      return false
    end
  end
  def store_location_for_login
    session[:return_to] = request.request_uri
  end
  def redirect_to_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
