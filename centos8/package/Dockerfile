FROM rdb-centos8-build

WORKDIR /platform/rethinkdb
RUN ln -s "$PWD"/build/release_clang build/release
RUN CXX=clang++ ./scripts/build-rpm.sh
