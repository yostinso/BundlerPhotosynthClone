module Paperclip
  class ThumbnailWithSkip < Thumbnail
    def initialize file, options = {}, attachment = nil
      @file = file
      @no_thumbnail = options[:no_thumbnail].nil? ? false : options[:no_thumbnail]
      if @no_thumbnail then
        options[:geometry] = "" if options[:geometry].nil?
      end
      super
    end
    def make
      return @file if @no_thumbnail
      super
    end
  end
end
