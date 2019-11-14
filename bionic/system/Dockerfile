FROM rdbcheckout AS priorcheckout

# This is weird, because rdbcheckout is bionic -- we keep the same
# pattern on other platforms.
FROM rdbcheckout

RUN mkdir /platform

COPY --from=priorcheckout /rdb /platform
