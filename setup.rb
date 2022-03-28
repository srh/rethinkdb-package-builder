#!/usr/bin/env ruby

require 'fileutils'
require 'optparse'

# Pro tip: You might have to run "sudo setup.rb ..."

# To save time and space, we build images for support libs for
# specific commits like v2.3.7 and 78cab9c3b (for v2.4.x), instead of
# all commits.

basedir = Dir.pwd()

# 78cab9c3b is after updating package versions and the latest QuickJS patch
default_support_commit = "78cab9c3b"
options = {
  :commit => "v2.4.2",
  :support_commit => default_support_commit,
  :support => false,
  :builds => false,
  :packages => false,
  :copy => false,
  :distro => nil,
  :dist => false,
  :docs => false,
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
  opts.on("--[no-]support", "Build support (default off)") { |s|
    options[:support] = s
  }
  opts.on("--[no-]packages", "Build packages (default off)") { |p|
    options[:packages] = p
    if p
      options[:support] = true
    end
  }
  opts.on("--[no-]builds", "Build builds (default off)") { |b|
    options[:builds] = b
    if b
      options[:support] = true
    end
  }
  opts.on("--distro DISTRO", "The distro to build packages for (default all)") { |d|
    if d == "all"
      options[:distro] = nil
    else
      options[:distro] = d
    end
  }
  opts.on("--dist", "Builds dist .tgz source file") { |b|
    options[:dist] = b
    if b
      options[:support] = true
    end
  }
  opts.on("--copy-dirs", "Copies packages directory to artifacts/") { |b|
    options[:copy] = (b ? :dir : false)
  }
  opts.on("--copy-pkgs", "Copies debs and rpms to artifacts/pkgs") { |b|
    options[:copy] = (b ? :pkgs : false)
  }
  opts.on("--v23support", "Build support libs for v2.3.x") { |b|
    options[:support_commit] = "v2.3.7"
  }
  opts.on("--v24support", "Build support libs for v2.4.0/v2.4.1") { |b|
    # b2365be is the "Parallelize deb-build" commit in v2.4.x.
    options[:support_commit] = "b2365bef6"
  }
  opts.on("--v242support", "Build support libs for v2.4.x, x>1") { |b|
    # We might want to update this commit hash later.
    options[:support_commit] = default_support_commit
  }
  opts.on("--docs", "Build docs for master branch") { |b|
    options[:docs] = b
  }
}

parser.parse!

commit = options[:commit]
support_commit = options[:support_commit]
package_args = "--build-arg commit=#{commit}"
checkout_args = "#{package_args} --build-arg support_commit=#{support_commit}"
build_args = "#{package_args}"
support_args = "--build-arg commit=#{support_commit}"

# distros is in order of priority.
distros = [
# latest production releases
  "bullseye",
  "jammy",
  "impish",
  "alma8",
  "rocky8",
#  "centos8",
# past production releases
  "centos7",
#  "centos6",
  "buster",
  "stretch",
  "jessie",
  "focal",
  "bionic",
  "xenial",
# unimportant releases
  "hirsute",
  "trusty",
]

if options[:distro] != nil
  if ["archlinux", "alpine"].include?(options[:distro])
    # We don't yet implement package builds for archlinux/alpine, we don't want the all-distros option to fail.
    distros = [options[:distro]]
  else
    distros.delete_if { |d| options[:distro] != d }
  end
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
  Dir.chdir("#{distro}") {
    system "docker build -t samrhughes/rdb-#{distro}-system -f System ." or raise "build rdb-#{distro}-system fail"
  }
}

if options[:docs]
  Dir.chdir("docs/docscheckout") {
    system "docker build -t samrhughes/rdb-docs-docscheckout ." or raise "build rdb-docs-docscheckout fail"
  }
  Dir.chdir("docs/system") {
    system "docker build -t samrhughes/rdb-docs-system ." or raise "build rdb-docs-system fail"
  }
  docs_commit = "e4be287c2"
  Dir.chdir("docs/build") {
    system "docker build -t samrhughes/rdb-docs-build:#{docs_commit} --build-arg commit=${docs_commit} ." or raise "build rdb-docs-build fail"
  }
end

if options[:support]
  # Then do support builds
  distros.each { |distro|
    Dir.chdir("#{distro}") {
      system "docker build -t samrhughes/rdb-#{distro}-support:#{support_commit} #{support_args} -f Support ." or raise "build rdb-#{distro}-support fail"
    }
  }

  # Then do checkouts
  distros.each { |distro|
    Dir.chdir("#{distro}") {
      system "docker build -t samrhughes/rdb-#{distro}-checkout:#{commit} #{checkout_args} -f Checkout ." or raise "build rdb-#{distro}-checkout fail"
    }
  }

  if options[:builds]
    # Then do builds, if we want that.
    distros.each { |distro|
      if distro == "centos6"
        Dir.chdir("#{distro}/build") {
          system "docker build -t samrhughes/rdb-#{distro}-build:#{commit} #{build_args} ." or raise "build rdb-#{distro}-build fail"
        }
      else
        Dir.chdir("build") {
          system "docker build -t samrhughes/rdb-#{distro}-build:#{commit} #{build_args} --build-arg distro=#{distro} ." or raise "build rdb-#{distro}-build fail"
        }
      end
    }
  end

  if options[:dist]
    # This focal build sequence is a (don't-repeat-yourself-violating)
    # copy of the ordering logic above, instead of having some system
    # to name dependencies and chase the graph.
    Dir.chdir("focal") {
      system "docker build -t samrhughes/rdb-focal-system -f System ." or raise "build rdb-focal-system fail"
      system "docker build -t samrhughes/rdb-focal-support:#{support_commit} #{support_args} -f Support ." or raise "build rdb-focal-support fail"
      system "docker build -t samrhughes/rdb-focal-checkout:#{commit} #{checkout_args} -f Checkout ." or raise "build rdb-focal-checkout fail"
    }

    Dir.chdir("dist") {
      # We only need one dist file, it doesn't depend on OS.  So we
      # pick a recent LTS ubuntu, focal, whose dependencies are
      # ensured immediately above.
      system "docker build -t samrhughes/rdb-focal-dist:#{commit} #{build_args} ." or raise "build rdb-focal-dist fail"
    }

    puts "Copying dist file into one pkgs directory..."
    FileUtils.mkdir_p("artifacts/pkgs")
    cmd = "docker run --rm -v #{basedir}/artifacts:/artifacts samrhughes/rdb-focal-dist:#{commit} bash -c \"cp \\$(find /platform/rethinkdb/build/packages -name '*.tgz') /artifacts/pkgs\""
    puts "Executing #{cmd}"
    system cmd or raise "copy-dist fail"
    puts "Done copying dist."
  end

  if options[:packages]
    # And build packages, if we want that.
    distros.each { |distro|
      Dir.chdir("#{distro}") {
        system "docker build -t samrhughes/rdb-#{distro}-package:#{commit} #{package_args} -f Package ." or raise "build rdb-#{distro}-package fail"
      }
    }

    if options[:copy] == :dir
      # TODO: Use rsync for --copy-dirs.  We'd have to install it on
      # the images though.
      distros.each { |distro|
        puts "Copying dir for distro #{distro}..."
        FileUtils.mkdir_p("artifacts/#{distro}")

        system "docker run --rm -v #{basedir}/artifacts:/artifacts samrhughes/rdb-#{distro}-package:#{commit} cp -R /platform/rethinkdb/build/packages /artifacts/#{distro}" or raise "copy-dirs #{distro}-package fail"
      }
      puts "Done copying dirs."
    elsif options[:copy] == :pkgs
      distros.each { |distro|
        puts "Copying deb/rpms for distro #{distro} into one directory..."
        FileUtils.mkdir_p("artifacts/pkgs")
        FileUtils.mkdir("artifacts/pkg_stage")

        cmd = "docker run --rm -v #{basedir}/artifacts:/artifacts samrhughes/rdb-#{distro}-package:#{commit} bash -c \"cp \\$(find /platform/rethinkdb/build/packages -name '*.deb' -or -name '*.rpm') /artifacts/pkg_stage\""
        puts "Executing #{cmd}"
        system cmd or raise "copy-pkgs #{distro}-package fail"
        Dir.glob("artifacts/pkg_stage/*").each { |ent|
          newname = File.basename(ent).gsub(/\.rpm$/, ".#{distro}.rpm")
          FileUtils.mv(ent, "artifacts/pkgs/#{newname}")
        }

        FileUtils.rmdir("artifacts/pkg_stage")
        puts "Done copying packages."
      }
    end
  end
end
