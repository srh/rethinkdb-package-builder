FROM samrhughes/rdb-disco-system
ARG commit

WORKDIR /platform/rethinkdb

RUN git fetch --all && git checkout ${commit}
RUN ./configure --allow-fetch CXX=clang++
RUN make clean

# Builds external packages
RUN make -j7 support
