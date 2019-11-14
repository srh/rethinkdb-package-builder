FROM samrhughes/rdbcheckout AS priorcheckout

FROM ubuntu:xenial

WORKDIR /platform/rethinkdb

RUN git checkout ${commit}
RUN ./configure --allow-fetch
RUN make clean

# Builds node, unfortunately
RUN make -j7 fetch
# Builds external packages
RUN make -j7 support
