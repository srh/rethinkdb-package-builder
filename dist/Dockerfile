ARG commit
FROM samrhughes/rdb-focal-checkout:${commit}

WORKDIR /platform/rethinkdb

RUN make dist
