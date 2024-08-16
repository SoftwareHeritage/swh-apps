# Deeply inspired from the Dockerfile of the swh-graphql project
FROM rust:1.80-bookworm
ARG UID=1000
ARG GID=1000

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y python3 python3-pip \
      libcmph-dev librdkafka-dev \
      build-essential libclang-dev \
      zstd protobuf-compiler default-jre && \
    apt clean && \
    addgroup --gid $UID swh && \
    useradd --gid $GID --uid $UID -m -d /opt/swh swh && \
    mkdir /etc/swh

USER swh
WORKDIR /opt/swh

COPY --chown=swh:swh requirements-frozen.txt /opt/swh

ENV PYTHONPATH=/opt/swh
ENV PATH=/opt/swh/.local/bin:$PATH

RUN /usr/bin/python3 -m pip install --upgrade pip --break-system-packages && \
    pip install --no-cache-dir -r requirements-frozen.txt --break-system-packages

# Install

RUN RUSTFLAGS="-C target-cpu=native" \
  cargo install \
    --features grpc-server \
    swh-graph

ENV SWH_CONFIG_FILENAME=/etc/swh/config.yml
ENV PORT 5009
EXPOSE $PORT

COPY --chown=swh:swh entrypoint.sh /opt/swh
RUN chmod u+x /opt/swh/entrypoint.sh

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
