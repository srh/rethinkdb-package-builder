#!/usr/bin/env ruby

require 'optparse'

options = {
  :commit => "v2.3.7",
  :packages => false,
  :distro => nil,
}
parser = OptionParser.new { |opts|
  opts.banner = "Usage: ./setup.rb [options]"
  opts.on("-c", "--commit COMMIT", "The commit to build packages for (default v2.3.7)") { |c|
    options[:commit] = c
  }
  opts.on("--[no-]packages", "Build packages (default off)") { |p|
    options[:packages] = p
  }
  opts.on("--distro DISTRO", "The distro to build packages for (default all)") { |d|
    puts("distro option ", d)
    if d == "all"
      options[:distro] = nil
    else
      options[:distro] = d
    end
  }
}

parser.parse!

# Building and packaging doesn't exactly belong here...

commit = options[:commit]
build_args = "--build-arg commit=#{commit}"

# distros is in order of priority.
distros = [
# latest production releases
  "bionic",
  "centos8",
  "buster",
# past production releases
  "centos7",
  "stretch",
  "jessie",
  "xenial",
  "trusty",
# unimportant releases
  "eoan",
  "disco",
]

if options[:distro] != nil
  distros = distros.filter { |d| options[:distro] == d }
end

if distros.empty?
  raise "Invalid distro"
end

# First build the base image
Dir.chdir("rdbcheckout") {
  system "docker build -t rdbcheckout ." or raise "build rdbcheckout fail"
}

# Then do builds
distros.each { |distro|
  Dir.chdir("#{distro}/build") {
    system "docker build -t rdb-#{distro}-build:#{commit} #{build_args} ." or raise "build rdb-#{distro}-build fail"
  }
}

if options[:packages]
  # Then build packages
  distros.each { |distro|
    Dir.chdir("#{distro}/package") {
      system "docker build -t rdb-#{distro}-package:#{commit} #{build_args} ." or raise "build rdb-#{distro}-package fail"
    }
  }
end
