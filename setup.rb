#!/usr/bin/env ruby

require 'fileutils'
require 'optparse'

# Pro tip: You might have to run "sudo setup.rb ..."

# To save time and space, we build images for support libs for
# specific commits like v2.3.7 and 38957e2c0 (for v2.4.4 and later),
# instead of all commits.  If you specify the wrong "support_commit"
# option, nothing will break, but you will end up rebuilding some
# support libraries because they changed.
#
# TODO: Look into default_commit's git history and automatically
# select the support commit to use.

basedir = Dir.pwd()

# 38957e2c0 is after the sha256sum patch
default_support_commit = "38957e2c0"
default_commit = "v2.4.4"
options = {
  :commit => default_commit,
  :support_commit => default_support_commit,
  # :yes, :no, or nil
  :support => nil,
  :builds => false,
  # :yes, :no, or nil
  :packages => nil,
  # :dir, :pkgs, or nil
  :copy => nil,
  :distro => nil,
  :dist => false,
  :docs => false,
  :test_packages => false,
}
parser = OptionParser.new { |opts|
  opts.banner = "Usage: ./setup.rb [options]"
  opts.on("-c", "--commit COMMIT", "The commit to build packages for (default #{default_commit})") { |c|
    if c[0] == "v"
      options[:commit] = c
    elsif c =~ /^[a-f0-9]{9,}$/
      options[:commit] = c[0...9]
    else
      raise "Commit must be \"v...\" or be hash of length 9"
    end
  }
  opts.on("--[no-]support", "Build support (default off)") { |s|
    options[:support] = s ? :yes : :no
  }
  opts.on("--[no-]packages", "Build packages (default off)") { |p|
    options[:packages] = p ? :yes : :no
  }
  opts.on("--[no-]builds", "Build builds (default off)") { |b|
    options[:builds] = b
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
  }
  opts.on("--copy-dirs", "Copies packages directory to artifacts/") { |b|
    if b
      raise "--copy-dirs is incompatible with --copy-pkgs" if options[:copy] == :pkgs
      options[:copy] = :dir
    end
  }
  opts.on("--copy-pkgs", "Copies debs and rpms to artifacts/pkgs") { |b|
    if b
      raise "--copy-dirs is incompatible with --copy-pkgs" if options[:copy] == :dirs
      options[:copy] = :pkgs
    end
  }
  opts.on("--test-pkgs", "Tests copied debs and rpms") { |b|
    options[:test_packages] = b
  }
  opts.on("--v23support", "Build support libs for v2.3.x") { |b|
    options[:support_commit] = "v2.3.7"
  }
  opts.on("--v24support", "Build support libs for v2.4.0/v2.4.1") { |b|
    # b2365be is the "Parallelize deb-build" commit in v2.4.x.
    options[:support_commit] = "b2365bef6"
  }
  opts.on("--v242support", "Build support libs for v2.4.x, 1<x<=2") { |b|
    # We might want to update this commit hash later.
    options[:support_commit] = "ca0eb820d"
  }
  opts.on("--v243support", "Build support libs for v2.4.x, x>2") { |b|
    # We might want to update this commit hash later.
    options[:support_commit] = default_support_commit
  }
  opts.on("--docs", "Build docs for master branch") { |b|
    options[:docs] = b
  }
}

parser.parse!


if options[:test_packages]
  if options[:copy] == :dir
    # I don't want to think about this right now, so we just require
    # --copy-pkgs to be used.
    raise "--test-pkgs is incompatible with --copy-dirs (out of sheer laziness)"
  end
  options[:copy] = :pkgs
end

if options[:copy] == :pkgs || options[:copy] == :dirs
  if options[:packages] == :no
    raise "--copy-#{options[:copy]} is incompatible with --no-packages"
  end
  options[:packages] = :yes
end

if options[:dist]
  raise "--dist is incompatible with --no-support" if options[:support] == :no
  options[:support] = :yes
end

if options[:builds]
  raise "--builds is incompatible with --no-support" if options[:support] == :no
  options[:support] = :yes
end

if options[:packages] == :yes
  raise "--packages is incompatible with --no-support" if options[:support] == :no
  options[:support] = :yes
end



commit = options[:commit]
support_commit = options[:support_commit]
package_args = "--build-arg commit=#{commit}"
checkout_args = "#{package_args} --build-arg support_commit=#{support_commit}"
build_args = "#{package_args}"
support_args = "--build-arg commit=#{support_commit}"

# distros is in order of priority.
distros = [
# latest production releases
  "bookworm",
  "noble",
  "mantic",
  "jammy",
  "alma8",
  "alma9",
  "rocky8",
  "rocky9",
#  "centos8",
# past production releases
  "centos7",

# working but normally commented.
#  "amazon2",
#  "amazon2023",
#  "archlinux",
#  "alpine3_15",
#  "alpine3_15i386",
#  "alpine3_16",
#  "alpine3_17",
#  "alpine3_18",
#  "alpine_edge",
#  "alpine_edgei386",

#  "centos6",
  "bullseye",
  "buster",
#  "stretch",
#  "jessie",
#  "kinetic",
  "lunar",
  "focal",
  "bionic",
  "xenial",
# unimportant releases
  "trusty",
#  "trustyi386",
]

if options[:distro] != nil
  if ["archlinux", "alpine3_15", "alpine3_15i386", "alpine3_16", "alpine3_17", "alpine3_18", "alpine_edge", "alpine_edgei386"].include?(options[:distro])
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
    system "docker build -t samrhughes/rdb-docs-build:#{docs_commit} --build-arg commit=#{docs_commit} ." or raise "build rdb-docs-build fail"
  }
end

if options[:support] == :yes
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

  if options[:packages] == :yes
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
      packages_map = {}

      distros.each { |distro|
        puts "Copying deb/rpms for distro #{distro} into one directory..."
        FileUtils.mkdir_p("artifacts/pkgs")
        FileUtils.mkdir("artifacts/pkg_stage")

        cmd = "docker run --rm -v #{basedir}/artifacts:/artifacts samrhughes/rdb-#{distro}-package:#{commit} bash -c \"cp \\$(find /platform/rethinkdb/build/packages -name '*.deb' -or -name '*.rpm') /artifacts/pkg_stage\""
        puts "Executing #{cmd}"
        system cmd or raise "copy-pkgs #{distro}-package fail"

        packages_map[distro] = []
        Dir.glob("artifacts/pkg_stage/*").each { |ent|
          newname = File.basename(ent).gsub(/\.rpm$/, ".#{distro}.rpm")
          FileUtils.mv(ent, "artifacts/pkgs/#{newname}")
          packages_map[distro].append(newname)
        }

        FileUtils.rmdir("artifacts/pkg_stage")
        puts "Done copying packages."
      }

      if options[:test_packages]
        distros.each { |distro|
          packages_map[distro].each { |package_filename|
            if package_filename !~ /-dbg/
              puts "Testing package install for #{package_filename}"
              system "docker build -t samrhughes/rdb-#{distro}-test:#{commit} --build-arg package_file='#{package_filename}' -f #{distro}/Test artifacts/pkgs" or raise "build rdb-#{distro}-test fail"
            end
          }
        }
      end
    end
  end
end
