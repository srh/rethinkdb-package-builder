FROM rdb-bionic-build

# DISAPPEND: Move this to rdbcheckout
RUN apt-get install -y curl

WORKDIR /platform/rethinkdb
RUN make -j7 build-deb UBUNTU_RELEASE=bionic
