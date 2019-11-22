ARG support_commit
FROM samrhughes/rdb-centos7-support:${support_commit}
ARG commit

WORKDIR /platform/rethinkdb

RUN git fetch && git checkout ${commit}
RUN ./configure --allow-fetch
