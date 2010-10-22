class User < ActiveRecord::Base
  has_many :photos
  has_many :photosets

  acts_as_authentic
end
