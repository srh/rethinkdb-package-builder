#!/usr/bin/env ruby

require 'fileutils'
require 'optparse'

basedir = Dir.pwd()

default_commit = "old_admin"

docker_build = "docker build --progress=plain"

options = {
  :commit => default_commit,
  :pversion => nil,
}

parser = OptionParser.new { |opts|
  opts.banner = "Usage: ./setup.rb [options]"
  opts.on("-c", "--commit COMMIT", "The commit to generate web_assets.cc for (default #{default_commit})") { |c|
    options[:commit] = c
  }
  opts.on("-v", "--version PVERSION", "The version number to generate into web_assets.cc (e.g. --version 2.4.5)") { |s|
    options[:pversion] = s
  }
}

parser.parse!

if options[:pversion] == nil
  raise "No --version option specified"
end

commit = options[:commit]
pversion = options[:pversion]

FileUtils.mkdir_p("artifacts")
Dir.chdir("admin_ui") {
  system "#{docker_build} -t samrhughes/admin_ui:#{commit} --build-arg commit=#{commit} --build-arg pversion=#{pversion} ." or raise "build admin_ui fail"
}
cmd = "docker run --rm -v #{basedir}/artifacts:/artifacts samrhughes/admin_ui:#{commit} bash -c \"cp /platform/rethinkdb/src/gen/web_assets.cc /artifacts/web_assets.cc\""
puts "Executing #{cmd}"
system cmd or raise "copy admin_ui fail"


