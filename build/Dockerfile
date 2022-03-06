ARG distro
ARG commit
FROM samrhughes/rdb-${distro}-checkout:${commit}

WORKDIR /platform/rethinkdb

RUN make -j3 DEBUG=1
RUN make -j3
