ARG commit
FROM rdb-bionic-build:${commit}

WORKDIR /platform/rethinkdb
RUN make -j7 build-deb UBUNTU_RELEASE=bionic
