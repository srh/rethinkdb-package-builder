FROM rdbcheckout AS priorcheckout

FROM centos:centos8
ARG commit

# General platform dependencies
RUN yum upgrade -y
RUN yum install -y openssl-devel libcurl-devel wget tar m4
RUN yum install -y git-core gcc-c++ which make python2 boost-devel
RUN yum install -y bzip2 patch clang

RUN yum install -y perl rubygems ruby-devel rpm-build
RUN gem install fpm

RUN alternatives --set python /usr/bin/python2

RUN mkdir /platform

# Copy cloned and mostly-fetched rethinkdb directory
COPY --from=priorcheckout /rdb /platform
WORKDIR /platform/rethinkdb

RUN git checkout ${commit}
RUN ./configure --allow-fetch CXX=clang++
RUN make clean

# Builds node, unfortunately
RUN make -j7 fetch
# Builds external packages
RUN make -j7 support

RUN make -j7
RUN make -j7 DEBUG=1

