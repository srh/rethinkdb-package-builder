FROM rdbcheckout AS priorcheckout

# This is weird, because rdbcheckout is bionic -- we keep the same
# pattern on other platforms.
FROM rdbcheckout

RUN mkdir /platform

COPY --from=priorcheckout /rdb /platform
WORKDIR /platform/rethinkdb

RUN git checkout v2.3.x
RUN ./configure --allow-fetch CXX=clang++
RUN make clean

# Builds node, unfortunately
RUN make -j7 fetch
# DISAPPEND: Uncomment this
# # Builds external packages
# RUN make -j7 support

RUN make -j7
RUN make -j7 DEBUG=1
