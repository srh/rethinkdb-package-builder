FROM rdbcheckout AS priorcheckout

FROM centos:centos7

# General platform dependencies
RUN yum upgrade -y
RUN yum install -y openssl-devel libcurl-devel wget tar m4
RUN yum install -y git-core boost-static gcc-c++ npm ncurses-devel
RUN yum install -y which make ncurses-static zlib-devel zlib-static
RUN yum install -y protobuf-devel protobuf-static jemalloc-devel
RUN yum install -y bzip2 patch

RUN yum install -y perl rubygems ruby-devel rpm-build
RUN gem install fpm

RUN alternatives --set python /usr/bin/python2

RUN mkdir /platform

# Copy cloned and mostly-fetched rethinkdb directory
COPY --from=priorcheckout /rdb /platform
WORKDIR /platform/rethinkdb

RUN git checkout v2.3.x
RUN ./configure --allow-fetch
RUN make clean

# Builds node, unfortunately
RUN make -j7 fetch
# Builds external packages
RUN make -j7 support

RUN make -j7
RUN make -j7 DEBUG=1

