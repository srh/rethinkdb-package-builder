FROM samrhughes/rdbcheckout AS priorcheckout

FROM archlinux:20200306

# General platform dependencies come before any other decision
RUN pacman -Syu --noconfirm clang
RUN pacman -Syu --noconfirm protobuf
RUN pacman -Syu --noconfirm boost
RUN pacman -Syu --noconfirm jemalloc
RUN pacman -Syu --noconfirm git
RUN pacman -Syu --noconfirm python2

ADD pythonscript /usr/local/bin/python
RUN chmod +x /usr/local/bin/python

RUN mkdir /platform

# Copy cloned and mostly-fetched rethinkdb directory
COPY --from=priorcheckout /rdb /platform

