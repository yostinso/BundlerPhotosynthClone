class User < ActiveRecord::Base
  has_many :photos
  has_many :photosets

  acts_as_authentic

  def guest?
    return self.login == "guest"
  end
end
