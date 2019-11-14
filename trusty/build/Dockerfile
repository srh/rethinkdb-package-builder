FROM rdbcheckout AS priorcheckout

FROM ubuntu:trusty

# General platform dependencies come before any other decision
RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get install -y git build-essential protobuf-compiler python
RUN apt-get install -y libprotobuf-dev libcurl4-openssl-dev libboost-all-dev
RUN apt-get install -y libncurses5-dev libjemalloc-dev wget m4 g++ libssl-dev
RUN apt-get install -y debhelper curl

# Untested is the libssl-dev dependency, which is conspicuously absent
# from http://samuelhughes.com/rethinkdb/build_instructions.html

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

