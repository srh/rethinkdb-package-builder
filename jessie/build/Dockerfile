ARG support_commit
FROM rdb-jessie-support:${support_commit}
ARG commit

WORKDIR /platform/rethinkdb

RUN git checkout ${commit}
RUN ./configure --allow-fetch

RUN make -j7
RUN make -j7 DEBUG=1

