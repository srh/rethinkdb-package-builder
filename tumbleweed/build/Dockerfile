FROM rdbcheckout AS priorcheckout

FROM opensuse/tumbleweed

# Starting from openSUSE server edition
RUN zypper -n install patch
RUN zypper -n install libopenssl-devel
RUN zypper -n install make
RUN zypper -n install git-core
RUN zypper -n install zlib-devel libcurl-devel
RUN zypper -n install clang8
RUN zypper -n install gcc

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

