class BundlerController
  module ResultCode
    KEYMATCH_FAILED = "Couldn't do keymatching/feature finding! (Step 1/?)"
    BUNDLE_FAILED = "Couldn't bundle images. Not a complete source set? (Step 2/?)"
    BUNDLE2PMVS_FAILED = "Couldn't generate CMVS/PMVS prereqs using bundle2pmvs. (Step 3/?)"
    UNDISTORT_FAILED = "Couldn't undistort images. (Step 4/?)"
    CMVS_FAILED = "Couldn't generate sparse point cloud using CMVS. (Step 5/?)"
    PMVS_FAILED = "Couldn't generate dense point cloud using PMVS. (Step 6/?)"
    NO_MODELS_GENERATED = "CMVS/PMVS failed to generate any actual models; bad bundliness."
    SUCCESS = "Success!"
  end
  BUNDLE_OUT_FILE = "bundle.out"
  BUNDLE_DIR = "bundle"

  PMVS_DIR = "pmvs"
  PMVS_TXT = "txt"
  PMVS_VIS = "visualize"
  PMVS_MODELS = "models"
  PMVS_OPTIONS_FILE = "pmvs_options-%04d.txt"
  BUNDLE_RD_OUT_FILE = "bundle.rd.out" # Contains bundle.out filtered by "good" images
  LIST_RD_FILE = "list.rd.txt" # Contains list of images filtereted by "good" images

  MATCHES_FILE = "matches.init.txt"
  SCRATCH_FILES = [
      MATCHES_FILE,
      File.join(BUNDLE_DIR, BUNDLE_OUT_FILE),
      File.join(PMVS_DIR, BUNDLE_RD_OUT_FILE),
      "constraints.txt",
      "matches.corresp.txt",
      "matches.prune.txt",
      "matches.ransac.txt",
      "nmatches.corresp.txt",
      "nmatches.prune.txt",
      "nmatches.ransac.txt",
      File.join(BUNDLE_DIR, "bundle.init.out"),
      File.join(PMVS_DIR, "ske.dat"),
      File.join(PMVS_DIR, "vis.dat"),
      File.join(PMVS_DIR, "centers-all.ply"),
  ]
  def initialize(bundle)
    raise Exception.new("Not a BundlerBundle") unless bundle.is_a?(BundlerBundle)
    @bundle = bundle
  end
  def bundle
    @bundle
  end
  def run
    # Clean up any existing files
    @bundle.bundler_files.each { |bf| bf.destroy }
    # TODO: Make bundler path a configuration option
    bundler_path = "/Users/yostinso/Downloads/bundler/bundler-v0.4-source/bin/bundler"
    # TODO: Make bundle2pmvs path a configuration option
    bundle2pmvs_path = "/Users/yostinso/Downloads/bundler/bundler-v0.4-source/bin/Bundle2PMVS"
    # TODO: Make KeyMatchFull path a configuration option
    keymatchfull_path = "/Users/yostinso/Downloads/bundler/bundler-v0.4-source/bin/KeyMatchFull"
    # TODO: Make RadialUndistort path a configuration option
    radialundistort_path = "/Users/yostinso/Downloads/bundler/bundler-v0.4-source/bin/RadialUndistort"
    # TODO: Make Bundle2Vis path a configuration option
    #bundle2vis_path =
    # TODO: Make CMVS path a configuration option
    cmvs_path = "/Users/yostinso/Downloads/bundler/cmvs/program/main/cmvs"
    # TODO: Make num_cpus a configuration option
    num_cpus = 2
    # TODO: Make maximage a configuration option
    maximage = 100
    # TODO: Make PMVS path a configuration option
    pmvs_path = "/Users/yostinso/Downloads/bundler/cmvs/program/main/pmvs2"


    scratch_dir = "/tmp/foo"

    # Create scratch_dirs
    FileUtils.mkdir_p(File.join(scratch_dir, BUNDLE_DIR))

    scratch_files = SCRATCH_FILES.map { |scratch_file| File.join(scratch_dir, scratch_file) }

    # Create keymatch file
    key_bf = make_bundler_file(scratch_dir, "list_keys.txt", @bundle.list.keys)
    success = system(keymatchfull_path, key_bf.file.path, File.join(scratch_dir, MATCHES_FILE))
    $stderr.puts [ keymatchfull_path, key_bf.file.path, File.join(scratch_dir, MATCHES_FILE) ].join(" ")
    if !success then
      clean_up_files(scratch_dir, scratch_files)
      return ResultCode::KEYMATCH_FAILED
    end
    key_bf.destroy

    options = make_bundler_options(scratch_dir)
    options["output"] = BUNDLE_OUT_FILE

    # Call bundler
    list_bf = make_bundler_file(scratch_dir, "list.txt", @bundle.list.focals)
    success = system(bundler_path, list_bf.file.path, *(options.as_args))
    $stderr.puts [ bundler_path, list_bf.file.path, *(options.as_args) ].join(" ")
    if !success then
      clean_up_files(scratch_dir, scratch_files)
      list_bf.destroy unless list_bf.nil?
      return ResultCode::BUNDLE_FAILED
    end
    list_bf.destroy

    # Grab the regular Bundler output
    (bundle_out_bf = BundlerFile.new(
        :name => BUNDLE_OUT_FILE,
        :file => File.new(File.join(scratch_dir, BUNDLE_DIR, BUNDLE_OUT_FILE)),
        :bundler_bundle => @bundle
    )).save

    scratch_files += Dir.glob(File.join(scratch_dir, BUNDLE_DIR, "points[0-9][0-9][0-9].ply"))

    # Run Bundle2PMVS
    FileUtils.mkdir_p(File.join(scratch_dir, PMVS_DIR))
    FileUtils.mkdir_p(File.join(scratch_dir, PMVS_DIR, PMVS_TXT))
    FileUtils.mkdir_p(File.join(scratch_dir, PMVS_DIR, PMVS_VIS))
    FileUtils.mkdir_p(File.join(scratch_dir, PMVS_DIR, PMVS_MODELS))

    pmvs_bf = make_bundler_file(scratch_dir, "list_pmvs.txt", @bundle.list.files)
    success = system(bundle2pmvs_path, pmvs_bf.file.path, bundle_out_bf.file.path, File.join(scratch_dir, PMVS_DIR, ""), "-scripted")
    $stderr.puts [bundle2pmvs_path, pmvs_bf.file.path, bundle_out_bf.file.path, File.join(scratch_dir, PMVS_DIR, ""), "-scripted"].join(" ")
    if !success then
      clean_up_files(scratch_dir, scratch_files)
      return ResultCode::BUNDLE2PMVS_FAILED
    end
    pmvs_txt_files = Dir.glob(File.join(scratch_dir, PMVS_DIR, "txt", "*.txt"))
    scratch_files += pmvs_txt_files

    # Run RadialUndistort, which makes NNNNNNNN.jpg in PMVS_DIR
    success = system(radialundistort_path, pmvs_bf.file.path, bundle_out_bf.file.path, File.join(scratch_dir, PMVS_DIR, ""), "-pmvs")
    $stderr.puts [ radialundistort_path, pmvs_bf.file.path, bundle_out_bf.file.path, File.join(scratch_dir, PMVS_DIR, ""), "-pmvs" ].join(" ")
    if !success then
      clean_up_files(scratch_dir, scratch_files)
      return ResultCode::UNDISTORT_FAILED
    end
    undistorted_files = Dir.glob(File.join(scratch_dir, PMVS_DIR, "visualize", "*.jpg"))
    scratch_files += undistorted_files
    # RadialUndistort also makes bundle.rd.out, which we pass to cmvs

    (bundle_rd = BundlerFile.new(
        :name => BUNDLE_RD_OUT_FILE,
        :file => File.new(File.join(scratch_dir, PMVS_DIR, BUNDLE_RD_OUT_FILE)),
        :bundler_bundle => @bundle
    )).save
    pmvs_bf.destroy


    # Run CMVS -- makes centers-NNNN.ply, centers-all.ply, ske.dat, vis.dat.
    success = system(cmvs_path, bundle_rd.file.path, File.join(scratch_dir, PMVS_DIR, ""), maximage.to_s, num_cpus.to_s)
    $stderr.puts [ cmvs_path, bundle_rd.file.path, File.join(scratch_dir, PMVS_DIR, ""), maximage.to_s, num_cpus.to_s ].join(" ")
    if !success then
      clean_up_files(scratch_dir, scratch_files)
      return ResultCode::CMVS_FAILED
    end
    cmvs_center_files = Dir.glob(File.join(scratch_dir, PMVS_DIR, "centers-[0-9][0-9][0-9][0-9].ply"))
    scratch_files += cmvs_center_files

    # Generate CMVS options
    option_files = Array.new
    cnum = 0
    File.open(File.join(scratch_dir, PMVS_DIR, "ske.dat")) { |f|
      f.readline
      (num_inputs, clusters) = f.readline.chomp.split(/ /).map { |i| i.to_i }
      (0...clusters).each { |cnum|
        opts = make_pmvs_options
        opts["CPU"] = num_cpus
        (num_images, num_discard_images) = f.readline.chomp.split(/ /).map { |i| i.to_i } # Cluster header
        cluster_images = f.readline.chomp.split(/ /).map { |i| i.to_i } # Cluster images
        discard_images = cluster_images.slice(num_images..-1)
        cluster_images = cluster_images.slice(0...num_images)
        opts["timages"] = [ cluster_images.size.to_s, cluster_images.join(" ") ].join(" ")
        opts["oimages"] = [ discard_images.size.to_s, discard_images.join(" ") ].join(" ")
        option_files.push make_bundler_file(scratch_dir, sprintf(PMVS_OPTIONS_FILE, cnum), opts.as_argtext)
      }
    }

    # Run PMVS
    success = true
    option_files.each { |pmvs_opts_bf|
      success &= system(pmvs_path, File.join(scratch_dir, PMVS_DIR, ""), pmvs_opts_bf.file.path, "-relative")
      $stderr.puts [ pmvs_path, File.join(scratch_dir, PMVS_DIR, ""), pmvs_opts_bf.file.path, "-relative" ].join(" ")
    }
    option_files.each { |pmvs_opts_bf| pmvs_opts_bf.destroy }
    if !success then
      clean_up_files(scratch_dir, scratch_files)
      return ResultCode::PMVS_FAILED
    end
    bundle_out_bf.destroy
    bundle_rd.destroy

    # Find the model files and turn them into BundlerFiles for later
    option_files.each { |pmvs_opts_bf|
      num = pmvs_opts_bf.name.match(/\d{4}/)[0]
      BundlerFile.new(
          :name => "model-#{num}.ply",
          :file => File.new(File.join(scratch_dir, PMVS_DIR, PMVS_MODELS, "#{pmvs_opts_bf.name}.ply")),
          :bundler_bundle => @bundle
      ).save
      BundlerFile.new(
          :name => "model-#{num}.pset",
          :file => File.new(File.join(scratch_dir, PMVS_DIR, PMVS_MODELS, "#{pmvs_opts_bf.name}.pset")),
          :bundler_bundle => @bundle
      ).save
      BundlerFile.new(
          :name => "model-#{num}.patch",
          :file => File.new(File.join(scratch_dir, PMVS_DIR, PMVS_MODELS, "#{pmvs_opts_bf.name}.patch")),
          :bundler_bundle => @bundle
      ).save
      scratch_files += [
          File.join(scratch_dir, PMVS_DIR, PMVS_MODELS, "#{pmvs_opts_bf.name}.ply"),
          File.join(scratch_dir, PMVS_DIR, PMVS_MODELS, "#{pmvs_opts_bf.name}.pset"),
          File.join(scratch_dir, PMVS_DIR, PMVS_MODELS, "#{pmvs_opts_bf.name}.patch")
      ]
    }
    # Check models for content

    failed = false
    @bundle.bundler_files.all.find_all { |bf| File.extname(bf.name) == ".pset" }.each { |bf|
      failed |= (File.size(bf.file.path) <= 1)
    }
    return ResultCode::NO_MODELS_GENERATED if failed
    return ResultCode::SUCCESS
  end
  private
  def clean_up_files(scratch_dir, scratch_files)
    scratch_files.each do |scratch_file|
      File.delete(scratch_file.is_a?(File) ? scratch_file.path : scratch_file)
    end

    [
        File.join(scratch_dir, PMVS_DIR, PMVS_TXT),
        File.join(scratch_dir, PMVS_DIR, PMVS_VIS),
        File.join(scratch_dir, PMVS_DIR, PMVS_MODELS),
        File.join(scratch_dir, PMVS_DIR),
        File.join(scratch_dir, BUNDLE_DIR),
        scratch_dir,
    ].each do |dir|
      begin
        # Clean up directories if possible
        Dir.rmdir(dir)
      rescue
        $stderr.puts "Couldn't remove dir: #{dir}"
        # Oh well
      end
    end
  end
  def make_bundler_options(scratch_dir)
    opts = {
        "match_table"             => File.join(scratch_dir, MATCHES_FILE),
        #"output_all"              => "bundle_",
        "output_dir"              => File.join(scratch_dir, BUNDLE_DIR),
        "variable_focal_length"   => true,
        "use_focal_estimate"      => true,
        "constrain_focal"         => true,
        "constrain_focal_weight"  => "0.0001",
        "estimate_distortion"     => true,
        "run_bundle"              => true,
        "scratch_dir"             => scratch_dir,
#        "key_dir"                 => File.join(scratch_dir, KEYFILE_DIR)
    }
    def opts.as_args
      self.map { |k, v| v === true ? "--#{k}" : "--#{k}=#{v}"}
    end
    return opts
  end
  def make_pmvs_options()
    opts = {
        "level"       => "1",
        "csize"       => "2",
        "threshold"   => "0.7",
        "wsize"       => "7",
        "minImageNum" => "3",
        "CPU"         => "8",
        "setEdge"     => "0",
        "useBound"    => "0",
        "useVisData"  => "1",
        "sequence"    => "-1",
        "maxAngle"    => "10",
        "quad"        => "2.0",
    }
    def opts.as_argtext
      self.map { |k, v| v === true ? k.to_s : "#{k} #{v}" }.join("\n")
    end
    return opts
  end
  def make_bundler_file(scratch_dir, filename, content)
    # Create list.txt for bundler and Bundle2PMVS
    f = File.new(File.join(scratch_dir, filename), "w")
    f.puts content
    f.close
    bff = File.new(File.join(scratch_dir, filename))
    bf = BundlerFile.new(
        :name => filename,
        :file => bff,
        :bundler_bundle => @bundle
    )
    bf.save
    File.unlink(f.path)
    return bf
  end
  def prep_pmvs()

  end

end