FROM samrhughes/rdb-jessie-system
ARG commit

WORKDIR /platform/rethinkdb

RUN git checkout ${commit}
RUN ./configure --allow-fetch
RUN make clean

# Builds external packages
RUN make -j3 support
