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

  @bundler_config = ApplicationController::bundler_config
  has_attached_file :image,
    :styles => {
      :medium => { :geometry => "300x200", :format => :png },
      :small_cropped => { :geometry => "100x100#", :format => :png },
    },
    :default_style => :medium,
    :convert_options => { :all => "-strip" },
    :url => @bundler_config["image_url"],
    :path => @bundler_config["image_path"]

  has_attached_file :processed_image,
    :styles => {
      :sifted => { :sift_bin => @bundler_config["sift_bin"], :whiny => true }
    },
    :url => @bundler_config["image_url"],
    :path => @bundler_config["image_path"],
    :processors => [ :sift ]

  process_in_background :processed_image
end
