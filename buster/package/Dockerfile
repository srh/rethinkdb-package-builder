ARG commit
FROM rdb-buster-build:${commit}

WORKDIR /platform/rethinkdb
RUN make -j7 build-deb DEB_RELEASE=buster
