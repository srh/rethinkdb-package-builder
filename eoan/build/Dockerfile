ARG support_commit
FROM rdb-eoan-support:${support_commit}
ARG commit

WORKDIR /platform/rethinkdb

RUN git checkout ${commit}
RUN ./configure --allow-fetch CXX=clang++

RUN make -j7
RUN make -j7 DEBUG=1

