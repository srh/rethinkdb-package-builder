ARG commit
FROM rdb-stretch-build:${commit}

WORKDIR /platform/rethinkdb
RUN make -j7 build-deb DEB_RELEASE=stretch
