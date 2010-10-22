require 'lib/paperclip_processors/sift'
require 'lib/paperclip_processors/thumbnail_with_skip'
class Picture < ActiveRecord::Base
  belongs_to :user
  belongs_to :photoset
  has_attached_file :image,
    :styles => {
      :medium => { :geometry => "300x200", :format => :png },
      :small_cropped => { :geometry => "100x100#", :format => :png },
      # TODO: Bacgkround sifting
      # :sifted => { :sift_bin => "/home/yostinso/bundle_test/bundler/bundler-v0.4-source/bin/sift", :no_thumbnail => true, :whiny => true }
    },
    :default_style => :medium,
    :convert_options => { :all => "-strip" },
    :url => "/dwp/system/:attachment/:id/:style/:filename",
    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
    :processors => [ :thumbnail_with_skip, :sift ]
end
