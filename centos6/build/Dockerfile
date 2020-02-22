ARG commit
FROM samrhughes/rdb-centos6-checkout:${commit}

WORKDIR /platform/rethinkdb

RUN scl enable devtoolset-2 -- make -j7 DEBUG=1
RUN scl enable devtoolset-2 -- make -j7
