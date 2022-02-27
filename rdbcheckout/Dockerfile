FROM ubuntu:jammy
RUN mkdir /rdb
WORKDIR /rdb

RUN apt-get update && apt-get install -y apt-utils
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git make g++ wget python3 bzip2
RUN ln /usr/bin/python3 /usr/bin/python

RUN git clone https://github.com/srh/rethinkdb
WORKDIR /rdb/rethinkdb

# This is also the v24support commit of setup.rb
RUN git checkout b2365bef6
RUN ./configure --fetch all
RUN make -j3 fetch-protobuf fetch-node fetch-boost fetch-v8 fetch-zlib \
    fetch-re2 fetch-libidn fetch-curl fetch-jemalloc
RUN make clean && rm config.mk
