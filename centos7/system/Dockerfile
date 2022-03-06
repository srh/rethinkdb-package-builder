FROM samrhughes/rdbcheckout AS priorcheckout

FROM centos:centos7

# General platform dependencies
RUN yum update -y && yum install -y openssl-devel libcurl-devel wget tar m4 \
    git-core boost-static gcc-c++ npm ncurses-devel \
    which make ncurses-static zlib-devel zlib-static \
    protobuf-devel protobuf-static jemalloc-devel \
    bzip2 patch \
    perl rubygems ruby-devel rpm-build \
    libquadmath-devel

RUN gem install ffi -v 1.12.0 && \
    gem install git -v 1.7.0 && \
    gem install fpm -v 1.14.1

RUN mkdir /platform

# Copy cloned and mostly-fetched rethinkdb directory
COPY --from=priorcheckout /rdb /platform
