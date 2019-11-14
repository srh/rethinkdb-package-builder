ARG commit
FROM rdb-trusty-build:${commit}

WORKDIR /platform/rethinkdb
RUN git clean -fd
RUN make -j7 build-deb UBUNTU_RELEASE=trusty
