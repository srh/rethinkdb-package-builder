FROM rdbcheckout AS priorcheckout

# This is weird, because rdbcheckout is bionic -- we keep the same
# pattern on other platforms.
FROM rdbcheckout
ARG commit

RUN mkdir /platform

COPY --from=priorcheckout /rdb /platform
WORKDIR /platform/rethinkdb

RUN git checkout ${commit}
RUN ./configure --allow-fetch CXX=clang++
RUN make clean

# DISAPPEND: Combine fetch and support, to reduce build time.  Maybe.

# Builds node, unfortunately
RUN make -j7 fetch
# Builds external packages
RUN make -j7 support
