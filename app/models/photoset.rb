class Photoset < ActiveRecord::Base
  has_many :pictures, :dependent => :destroy
  has_many :bundler_bundles, :dependent => :destroy
  belongs_to :user
end
