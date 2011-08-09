class BundlerFile < ActiveRecord::Base
  belongs_to :bundler_bundle

  has_attached_file :file
end
