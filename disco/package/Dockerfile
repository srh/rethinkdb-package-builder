ARG commit
FROM samrhughes/rdb-disco-checkout:${commit}

WORKDIR /platform/rethinkdb
RUN git clean -fd
RUN make -j7 build-deb UBUNTU_RELEASE=disco
