FROM rust:1.80-bookworm AS rust_build
# ... build swh-graph rust deps
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y build-essential libclang-dev \
    zstd protobuf-compiler default-jre && \
    apt clean

# Install swh-graph feature swh-graph-grpc-serve
# TODO: Ensure the target-cpu is ok
RUN RUSTFLAGS="-C target-cpu=native" \
  cargo install swh-graph swh-graph-grpc-server

FROM python:3.10-bookworm

# Add necessary deps for compressed graph
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y zstd && \
    apt clean

ARG UID=1000
ARG GID=1000

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y python3-pip \
      libcmph-dev librdkafka-dev zstd && \
    apt clean && \
    addgroup --gid $UID swh && \
    useradd --gid $GID --uid $UID -m -d /opt/swh swh && \
    mkdir /etc/swh

RUN mkdir -p /srv/graph /srv/dataset
RUN chown $UID:$GID /srv/graph /srv/dataset
VOLUME /srv/graph /srv/dataset

USER swh
RUN /usr/local/bin/python -m venv /opt/swh/venv
WORKDIR /opt/swh

ENV PYTHONPATH=/opt/swh/venv
ENV PATH=/opt/swh/venv/bin:$PATH

RUN python -m pip install uv
COPY --chown=swh:swh requirements-frozen.txt /opt/swh
RUN uv pip sync --no-cache requirements-frozen.txt

COPY --from=rust_build /usr/local/cargo/bin/swh-graph* /usr/local/bin/
ENV SWH_CONFIG_FILENAME=/etc/swh/config.yml
ENV PORT 5009
EXPOSE $PORT

COPY --chown=swh:swh entrypoint.sh /opt/swh
RUN chmod u+x /opt/swh/entrypoint.sh

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
