ARG distro
ARG commit
FROM samrhughes/rdb-${distro}-checkout:${commit}

WORKDIR /platform/rethinkdb

RUN make -j7 DEBUG=1 ALLOW_WARNINGS=0
RUN make -j7 ALLOW_WARNINGS=0
