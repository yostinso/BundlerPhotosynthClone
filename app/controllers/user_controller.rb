class UserController < ApplicationController
  def index
    @photosets = current_user.photosets # PhotoSet.find_all_by_user_id(@
  end
end
