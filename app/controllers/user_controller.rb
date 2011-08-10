class UserController < ApplicationController
  before_filter :require_user
  def index
    @photosets = current_user.photosets
    @public_photosets = Photoset.find_all_by_public(true) - @photosets
  end
end
