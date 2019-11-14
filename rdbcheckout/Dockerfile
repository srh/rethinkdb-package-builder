FROM ubuntu:bionic
RUN mkdir /rdb
WORKDIR /rdb

RUN apt-get update && apt-get install -y \
    git build-essential protobuf-compiler python \
    libprotobuf-dev libcurl4-openssl-dev libboost-all-dev \
    libncurses5-dev libjemalloc-dev wget m4 clang libssl-dev \
    debhelper curl

RUN git clone https://github.com/srh/rethinkdb
WORKDIR /rdb/rethinkdb

# DISAPPEND: git checkout v2.3.7
RUN git checkout v2.3.x
RUN ./configure --fetch all CXX=clang++
RUN make -j3 fetch-protobuf fetch-node fetch-boost fetch-v8 fetch-zlib
RUN make -j3 fetch-openssl fetch-libidn fetch-curl fetch-jemalloc

RUN rm config.mk

