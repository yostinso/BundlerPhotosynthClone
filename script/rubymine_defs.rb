$: << "/Applications/Productivity/RubyMine9.app/rb/api/"
require 'code_insight/code_insight_helper'

describe "ApplicationController" do
  routes = []
  routes_file = File.join(File.expand_path(File.dirname(__FILE__)), "..", "config", "routes.rb")
  File.open(routes_file) { |f|
    f.each { |line|
      as = line.match(/:as\s*=>\s*"([^"]+)"/)
      next if as.nil?
      routes.push(as[1])
    }
  }
  $stderr.puts "Routes: from #{routes_file}: " + routes.join(",")
  routes.each { |as|
    set_dynamic_methods :methods => "#{as}_url", :method_to_resolve => "ActionDispatch::Routing::UrlFor.url_for"
  }
end
