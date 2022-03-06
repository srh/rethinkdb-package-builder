ARG commit
FROM samrhughes/rdb-jessie-checkout:${commit}

WORKDIR /platform/rethinkdb
# We refetch to get any last-minute tags.
RUN git fetch --all && git clean -fd
RUN make -j3 build-deb DEB_RELEASE=jessie
