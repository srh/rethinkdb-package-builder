FROM samrhughes/rdbcheckout AS priorcheckout

FROM alpine:3.11.5

# General platform dependencies come before any other decision
RUN apk update && apk add clang git bash bunitls musl-dev \
    gcc g++ python make perl linux-headers

RUN mkdir /platform

# Copy cloned and mostly-fetched rethinkdb directory
COPY --from=priorcheckout /rdb /platform

