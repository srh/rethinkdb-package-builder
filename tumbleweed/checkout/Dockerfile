ARG support_commit
FROM samrhughes/rdb-tumbleweed-support:${support_commit}
ARG commit

WORKDIR /platform/rethinkdb

RUN git remote add srh https://github.com/srh/rethinkdb.git
RUN git fetch --all && git checkout ${commit}
RUN ./configure --allow-fetch CXX=clang++
