module Paperclip
  class Sift < Processor
      require 'pp'
    def initialize(file, options = {}, attachment = nil)
      @file = file
      if options[:sift_bin] then
        @sift_bin            = File.basename(options[:sift_bin])
        @sift_bin_path       = File.dirname(options[:sift_bin])
      end
      @basename            = File.basename(@file.path)
      @whiny               = options[:whiny].nil? ? true : options[:whiny]
    end
    def make
      return file unless @sift_bin
      src = @file
      pgm = Tempfile.new([@basename, ".pgm"])
      dst = Tempfile.new([@basename, ".sift"])
      pgm.binmode
      dst.binmode

      begin
        # Convert to PGM
        success = Paperclip.run("convert", "-format pgm :source :pgm", :source => File.expand_path(src.path), :pgm => File.expand_path(pgm.path))

        # SIFT the PGM
        CommandLine.path = @sift_bin_path
        success = CommandLine.new(@sift_bin, "-o :dest :pgm", :pgm => File.expand_path(pgm.path), :dest => File.expand_path(dst.path), :expected_outcodes => [0] ).run
      rescue PaperclipCommandLineError => e
        raise PaperclipError, "There was an error generating the sift file for #{@basename}: #{e}" if @whiny
      end
      pgm.close(true) # Unlink and remove PGM

      dst
    end
  end
end
