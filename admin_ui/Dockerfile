FROM samrhughes/rdbcheckout AS priorcheckout

FROM ubuntu:focal

ARG commit
ARG pversion

# General platform dependencies come before any other decision
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata \
    && ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get update && apt-get install -y \
    git build-essential g++ curl \
    python wget

RUN mkdir /platform

# Copy cloned and mostly-fetched rethinkdb directory
COPY --from=priorcheckout /rdb /platform

WORKDIR /platform/rethinkdb

RUN git fetch --all && git checkout ${commit}

RUN ./configure --fetch all
RUN make clean
RUN make PVERSION=${pversion} -j7 generate

