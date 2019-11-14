ARG commit
FROM rdb-disco-build:${commit}

WORKDIR /platform/rethinkdb
RUN make -j7 build-deb UBUNTU_RELEASE=disco
