FROM ubuntu:bionic
RUN mkdir /rdb
WORKDIR /rdb

RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get install -y git
RUN apt-get install -y build-essential protobuf-compiler python
RUN apt-get install -y libprotobuf-dev libcurl4-openssl-dev libboost-all-dev
RUN apt-get install -y libncurses5-dev libjemalloc-dev wget m4 clang libssl-dev
RUN apt-get install -y debhelper

RUN git clone https://github.com/srh/rethinkdb
WORKDIR /rdb/rethinkdb

RUN git checkout v2.3.x
RUN ./configure --fetch all CXX=clang++
RUN make -j3 fetch-protobuf fetch-node fetch-boost fetch-v8 fetch-zlib
RUN make -j3 fetch-openssl fetch-libidn fetch-curl fetch-jemalloc

RUN rm config.mk

