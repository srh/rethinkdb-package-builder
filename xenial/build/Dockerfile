ARG support_commit
FROM samrhughes/rdb-xenial-support:${support_commit}
ARG commit

WORKDIR /platform/rethinkdb

RUN git fetch && git checkout ${commit}
RUN ./configure --allow-fetch

RUN make -j7
RUN make -j7 DEBUG=1

