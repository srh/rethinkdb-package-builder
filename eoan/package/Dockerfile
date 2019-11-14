ARG commit
FROM samrhughes/rdb-eoan-build:${commit}

WORKDIR /platform/rethinkdb
RUN git clean -fd
RUN make -j7 build-deb UBUNTU_RELEASE=eoan
