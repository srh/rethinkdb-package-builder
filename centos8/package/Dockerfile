ARG commit
FROM samrhughes/rdb-centos8-checkout:${commit}

WORKDIR /platform/rethinkdb
RUN git clean -fd
RUN ln -s "$PWD"/build/release_clang build/release
RUN CXX=clang++ ./scripts/build-rpm.sh
