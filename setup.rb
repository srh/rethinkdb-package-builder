#!/usr/bin/env ruby

basedir = Dir.pwd

# TODO: Ensure we handle errors when `system calls` fail.

Dir.chdir("rdbcheckout") {
  system "docker build -t rdbcheckout ." or raise "build rdbcheckout fail"
}

# Building and packaging doesn't exactly belong here...

commit = "v2.3.7"
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


# First do builds
distros.each { |distro|
  Dir.chdir("#{distro}/build") {
    system "docker build -t rdb-#{distro}-build:#{commit} #{build_args} ." or raise "build rdb-#{distro}-build fail"
  }
}

# Then build packages
distros.each { |distro|
  Dir.chdir("#{distro}/package") {
    system "docker build -t rdb-#{distro}-package:#{commit} #{build_args} ." or raise "build rdb-#{distro}-package fail"
  }
}
