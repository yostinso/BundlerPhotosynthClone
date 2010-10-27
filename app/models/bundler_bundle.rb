class BundlerBundle < ActiveRecord::Base
  belongs_to :photoset
  has_attached_file :bundle_lists,
    :styles => {
      :list => { :type => :list },
      :key_list => { :type => :key_list }
    }
    :default_style => :list,
    :url => "/dwp/system/:attachment/:id/:style/:filename",
    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
    :processors => [ :bundler ]
    
end
