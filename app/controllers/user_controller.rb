class UserController < ApplicationController
  before_filter :require_user
  def index
    @photosets = current_user.photosets # PhotoSet.find_all_by_user_id(@
  end
end
