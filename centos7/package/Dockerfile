ARG commit
FROM samrhughes/rdb-centos7-checkout:${commit}

WORKDIR /platform/rethinkdb
RUN git clean -fd
RUN ./scripts/build-rpm.sh
