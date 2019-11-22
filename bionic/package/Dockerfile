ARG commit
FROM samrhughes/rdb-bionic-checkout:${commit}

WORKDIR /platform/rethinkdb

# Clean "dirty" files, most likely external re2, which changes from
# 2.3.x to 2.4.x.
RUN git clean -fd

RUN make -j7 build-deb UBUNTU_RELEASE=bionic
