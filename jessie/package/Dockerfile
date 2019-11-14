ARG commit
FROM rdb-jessie-build:${commit}

WORKDIR /platform/rethinkdb
RUN make -j7 build-deb DEB_RELEASE=jessie
