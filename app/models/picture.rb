class Picture < ActiveRecord::Base
  belongs_to :user
  has_attached_file :image,
    :styles => { :medium => [ "300x200", :png ], :small_cropped => [ "100x100#", :png ] },
    :default_style => :medium,
    :convert_options => { :all => "-strip" }
end
