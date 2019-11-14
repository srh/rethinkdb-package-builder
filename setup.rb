#!/usr/bin/env ruby

basedir = Dir.pwd

# TODO: Ensure we handle errors when `system calls` fail.

Dir.chdir("rdbcheckout") {
  system "docker build -t rdbcheckout ." or raise "build rdbcheckout fail"
}

# Building and packaging doesn't exactly belong here...

commit = "v2.3.7"
build_args = "--build-arg commit=#{commit}"

Dir.chdir("bionic/build") {
  system "docker build -t rdb-bionic-build:#{commit} #{build_args} ." or raise "build rdb-bionic-build fail"
}

Dir.chdir("bionic/package") {
  system "docker build -t rdb-bionic-package:#{commit} #{build_args} ." or raise "build rdb-bionic-package fail"
}


