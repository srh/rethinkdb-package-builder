ARG commit
FROM samrhughes/rdb-stretch-checkout:${commit}

WORKDIR /platform/rethinkdb
RUN git clean -fd
RUN make -j7 build-deb DEB_RELEASE=stretch
