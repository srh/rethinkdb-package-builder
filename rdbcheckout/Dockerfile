FROM ubuntu:focal
RUN mkdir /rdb
WORKDIR /rdb

RUN apt-get update && apt-get install -y apt-utils
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git make g++ wget python3 python-is-python3 bzip2 xz-utils

RUN git clone https://github.com/srh/rethinkdb
WORKDIR /rdb/rethinkdb

# This is also the v242support commit of setup.rb
RUN git fetch --all && git checkout 38957e2c0
RUN ./configure --fetch all
RUN make -j3 fetch-boost fetch-curl fetch-gtest fetch-jemalloc \
    fetch-libidn fetch-openssl fetch-protobuf fetch-quickjs \
    fetch-re2 fetch-zlib
RUN make clean && rm config.mk
