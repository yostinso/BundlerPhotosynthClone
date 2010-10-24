require 'lib/paperclip_processors/sift'
class Picture < ActiveRecord::Base
  def initialize(options)
    super
    if options[:image] then
      self.processed_image = options[:image]
    end
  end
  belongs_to :user
  belongs_to :photoset
  has_attached_file :image,
    :styles => {
      :medium => { :geometry => "300x200", :format => :png },
      :small_cropped => { :geometry => "100x100#", :format => :png },
    },
    :default_style => :medium,
    :convert_options => { :all => "-strip" },
    :url => "/dwp/system/:attachment/:id/:style/:filename",
    :path => ":rails_root/public/system/:attachment/:id/:style/:filename"

  has_attached_file :processed_image,
    :styles => {
      :sifted => { :sift_bin => "/home/yostinso/bundle_test/bundler/bundler-v0.4-source/bin/sift", :whiny => true }
    },
    :url => "/dwp/system/:attachment/:id/:style/:filename",
    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
    :processors => [ :sift ]

  process_in_background :processed_image
end
