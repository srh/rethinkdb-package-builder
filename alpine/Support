FROM samrhughes/rdb-alpine-system
ARG commit

WORKDIR /platform/rethinkdb

RUN git fetch --all && git checkout ${commit}

# TODO: Consider adding jemalloc-dev, boost-dev, etc, instead of fetching externally.

RUN ./configure --allow-fetch CXX=clang++
RUN make clean

# Builds external packages
RUN make -j7 support
