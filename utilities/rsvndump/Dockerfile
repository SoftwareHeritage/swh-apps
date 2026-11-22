# Build svnrdump
FROM debian:trixie AS rsvndump
ARG VERSION=0.6.1
ARG TARBALL_NAME=rsvndump-${VERSION}
ARG TARBALL=${TARBALL_NAME}.tar.gz
ARG SHA512SUM=36167a9e56c4be543ef223dee475a686207b0595cd587f8c8e1ad4fb6144b6c4a734d17ff0024040b8691a2c84a3dc66cba32e91942d196fd1137943acb81879
ARG CHECKSUMS=${TARBALL}.sha512
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y build-essential wget coreutils
RUN wget https://sourceforge.net/projects/rsvndump/files/rsvndump/${TARBALL_NAME}/${TARBALL}/download -O ${TARBALL}
RUN echo "${SHA512SUM}  ${TARBALL}" > ${CHECKSUMS}
RUN sha512sum -c ${CHECKSUMS}
RUN tar xvf $TARBALL -C /tmp/
RUN apt-get -y install libapr1-dev libaprutil1-dev libsvn-dev
WORKDIR /tmp/${TARBALL_NAME}
RUN ./configure && make && make install
