ARG commit
FROM rdb-centos7-build:${commit}

WORKDIR /platform/rethinkdb
RUN git clean -fd
RUN ./scripts/build-rpm.sh
