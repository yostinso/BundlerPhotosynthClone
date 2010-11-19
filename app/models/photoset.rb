class Photoset < ActiveRecord::Base
  has_many :pictures, :dependent => :destroy
  has_many :bundler_bundles, :dependent => :destroy
  belongs_to :user

  def can_bundle?
    self.pictures.all.size > 1 && self.pictures.all.find {|pic| pic.processed_image_processing }.nil?
  end
end
