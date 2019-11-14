FROM rdbcheckout AS priorcheckout

FROM debian:stretch

# General platform dependencies come before any other decision
RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get install -y build-essential protobuf-compiler python
RUN apt-get install -y libprotobuf-dev libcurl4-openssl-dev libboost-all-dev
RUN apt-get install -y libncurses5-dev wget m4 clang libssl1.0-dev
RUN apt-get install -y debhelper curl
RUN apt-get install -y git

RUN mkdir /platform

# Copy cloned and mostly-fetched rethinkdb directory
COPY --from=priorcheckout /rdb /platform
WORKDIR /platform/rethinkdb

RUN git checkout v2.3.x
RUN ./configure --allow-fetch CXX=clang++
RUN make clean

# Builds node, unfortunately
RUN make -j7 fetch
# Builds external packages
RUN make -j7 support

RUN make -j7
RUN make -j7 DEBUG=1
