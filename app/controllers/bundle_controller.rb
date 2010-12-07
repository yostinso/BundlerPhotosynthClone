class BundleController < ApplicationController
  before_filter :require_user
  before_filter :require_bundle

  def view
    @bundle_plys = @bundle.bundler_files.all.find_all { |bf| File.extname(bf.name) == ".ply" }
    if @bundle_plys.empty? then
      flash[:error] = "No points file found for Bundle #{@bundle.id}."
      redirect_to manage_photoset_url(@bundle.photoset)
      return
    end
  end

  def ply_as_asc
    begin
      bf = @bundle.bundler_files.find(params[:bundler_file_id])
    rescue
      render :text => "No PLY file #{params[:bundler_file_id]} found for Bundle #{@bundle.id}."
      return
    end

    self.response_body = proc { |response, output|
      # Generate ASC from PLY
      at_data = false
      File.open(bf.file.path) { |f|
        f.each { |line|
          line.chomp!
          if line == "end_header" then
            at_data = true
            next
          end
          next unless at_data
          fields = line.split(/ /)
          # Convert XYZ NX NY NZ RGB to XYZ RGB NX NY NZ
          outline = [ fields[0], fields[1], fields[2], fields[6], fields[7], fields[8], fields[3], fields[4], fields[5] ].join(" ")
          output.write outline + $/
          # XXX: Does this actually stream content?
        }
      }
    }
  end
  def ply
    begin
      bf = @bundle.bundler_files.find(params[:bundler_file_id])
    rescue
      render :text => "No PLY file #{params[:bundler_file_id]} found for Bundle #{@bundle.id}."
      return
    end

    send_file bf.file.path, :disposition => "inline", :type => "text/plain"
  end
  private
  def require_bundle
    begin
      @bundle = BundlerBundle.find_by_id(params[:id])
      @bundle = nil unless @bundle.photoset.user_id = current_user.id
    rescue
    ensure
      unless @bundle then
        flash[:warning] = "Couldn't find bundle by ID #{params[:id]} for user #{current_user.id}"
        redirect_to user_home_url
      end
    end
  end
end