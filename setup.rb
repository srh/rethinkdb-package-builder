#!/usr/bin/env ruby

require 'optparse'

# Pro tip: You might have to run "sudo setup.rb ..."

# To save time and space, we build images for support libs for
# specific commits like v2.3.7 and b2365be (for v2.4.x), instead of
# all commits.

options = {
  :commit => "v2.3.7",
  :support_commit => "v2.3.7",
  :support => true,
  :builds => true,
  :packages => false,
  :distro => nil,
}
parser = OptionParser.new { |opts|
  opts.banner = "Usage: ./setup.rb [options]"
  opts.on("-c", "--commit COMMIT", "The commit to build packages for (default v2.3.7)") { |c|
    if c[0] == "v" || c.length == 9
      options[:commit] = c
    else
      raise "Commit must be \"v...\" or be hash of length 9"
    end
  }
  opts.on("--[no-]packages", "Build packages (default off)") { |p|
    options[:packages] = p
  }
  opts.on("--[no-]builds", "Build builds (default on)") { |b|
    options[:builds] = b
  }
  opts.on("--[no-]support", "Build support (default on)") { |s|
    options[:support] = s
  }
  opts.on("--distro DISTRO", "The distro to build packages for (default all)") { |d|
    if d == "all"
      options[:distro] = nil
    else
      options[:distro] = d
    end
  }
  opts.on("--v24support", "Build support libs for v2.4.x") { |b|
    # b2365be is the "Parallelize deb-build" commit in v2.4.x.
    options[:support_commit] = "b2365bef6"
  }
}

parser.parse!

commit = options[:commit]
support_commit = options[:support_commit]
package_args = "--build-arg commit=#{commit}"
build_args = "#{package_args} --build-arg support_commit=#{support_commit}"
build_args_support = "--build-arg commit=#{support_commit}"

artifact_dir = "artifacts"
Dir.mkdir(artifact_dir) unless File.directory?(artifact_dir)

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
  distros.delete_if { |d| options[:distro] != d }
end

if distros.empty?
  raise "Invalid distro"
end

# First build the base image
Dir.chdir("rdbcheckout") {
  system "docker build -t samrhughes/rdbcheckout ." or raise "build rdbcheckout fail"
}

# Then do system builds
distros.each { |distro|
  Dir.chdir("#{distro}/system") {
    system "docker build -t samrhughes/rdb-#{distro}-system ." or raise "build rdb-#{distro}-system fail"
  }
}

if options[:support]
  # Then do support builds
  distros.each { |distro|
    Dir.chdir("#{distro}/support") {
      system "docker build -t samrhughes/rdb-#{distro}-support:#{support_commit} #{build_args_support} ." or raise "build rdb-#{distro}-support fail"
    }
  }

  if options[:builds]
    # Then do builds
    distros.each { |distro|
      Dir.chdir("#{distro}/build") {
        system "docker build -t samrhughes/rdb-#{distro}-build:#{commit} #{build_args} ." or raise "build rdb-#{distro}-build fail"
      }
    }

    if options[:packages]
      # Then build packages
      distros.each { |distro|
        Dir.chdir("#{distro}/package") {
          system "docker build -t samrhughes/rdb-#{distro}-package:#{commit} #{package_args} ." or raise "build rdb-#{distro}-package fail"
        }

        # Extract artifacts from the build container
        system "docker run -v ${PWD}:/opt/mount --rm --entrypoint tar samrhughes/rdb-#{distro}-package:#{commit} -czvf /opt/mount/#{artifact_dir}/#{distro}.tar.gz /platform/rethinkdb/build/packages" or raise "build rdb-#{distro}-package fail"
      }
    end
  end
end
