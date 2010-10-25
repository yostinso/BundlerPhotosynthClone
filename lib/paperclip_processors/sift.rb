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
      vlfeat = Tempfile.new([@basename, ".key.vlfeat"])
      dst = Tempfile.new([@basename, ".key"])
      pgm.binmode
      vlfeat.binmode
      dst.binmode

      begin
        # Convert to PGM
        success = Paperclip.run("convert", "-format pgm :source :pgm", :source => File.expand_path(src.path), :pgm => File.expand_path(pgm.path))

        # SIFT the PGM
        CommandLine.path = @sift_bin_path
        success = CommandLine.new(@sift_bin, "-o :vlfeat :pgm", :pgm => File.expand_path(pgm.path), :vlfeat => File.expand_path(vlfeat.path), :expected_outcodes => [0] ).run

        # Convert the SIFT from VLFeat to Lowe formatting
        CommandLine.path = nil
        awk_cmd = 'function main() { printlines = ""; i1 = 0; tmp = $1; $1 = $2; $2 = tmp; for (i=1; i<9; i++) { i2 = offsets[i]; out = ""; for (j=i1+1; j<=i2; j++) { if (j != i1+1) { out = out " " }; out = out $j }; i1 = i2; if (printlines == "") { printlines = out; } else { printlines = printlines "\n" out; } } return printlines; } BEGIN { split("4 24 44 64 84 104 124 132", offsets); getline; cmd = "wc -l " FILENAME; printlines = main(); cmd | getline; lines = $1; print lines " 128"; print printlines; } { print main() }'
        success = CommandLine.new("awk", "'#{awk_cmd}' :vlfeat > :dst", :vlfeat => File.expand_path(vlfeat.path), :dst => File.expand_path(dst.path), :expected_outcodes => [0] ).run
      rescue PaperclipCommandLineError => e
        raise PaperclipError, "There was an error generating the sift file for #{@basename}: #{e}" if @whiny
      end
      pgm.close(true) # Unlink and remove PGM

      dst
    end
  end
end
