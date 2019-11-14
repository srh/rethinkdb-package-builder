ARG commit
FROM rdb-eoan-build:${commit}

WORKDIR /platform/rethinkdb
RUN make -j7 build-deb UBUNTU_RELEASE=eoan
