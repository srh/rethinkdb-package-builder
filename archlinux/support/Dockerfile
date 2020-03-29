FROM samrhughes/rdb-archlinux-system
ARG commit

WORKDIR /platform/rethinkdb

RUN git checkout ${commit}

# TODO: Move to system, of course.
RUN pacman -Syu --noconfirm make

RUN ./configure --allow-fetch CXX=clang++
RUN make clean

# Builds external packages
RUN make -j7 support
