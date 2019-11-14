ARG commit
FROM rdb-centos7-build:${commit}

WORKDIR /platform/rethinkdb
RUN ./scripts/build-rpm.sh
