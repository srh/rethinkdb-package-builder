FROM samrhughes/rdbcheckout AS priorcheckout

# This is weird, because rdbcheckout is bionic -- we keep the same
# pattern on other platforms.
FROM samrhughes/rdbcheckout

RUN mkdir /platform

COPY --from=priorcheckout /rdb /platform
