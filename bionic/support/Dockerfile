FROM rdb-bionic-system
ARG commit

WORKDIR /platform/rethinkdb

RUN git checkout ${commit}
RUN ./configure --allow-fetch CXX=clang++
RUN make clean

# DISAPPEND: Combine fetch and support, to reduce build time.  Maybe.

# Builds node, unfortunately
RUN make -j7 fetch
# Builds external packages
RUN make -j7 support
