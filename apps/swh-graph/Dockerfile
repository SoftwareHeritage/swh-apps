# Deeply inspired from the Dockerfile of the swh-graphql project
FROM python:3.11-bookworm
ARG UID=1000
ARG GID=1000

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev librdkafka-dev \
      build-essential libclang-dev \
      zstd protobuf-compiler && \
    apt clean && \
    addgroup --gid $UID swh && \
    useradd --gid $GID --uid $UID -m -d /opt/swh swh && \
    mkdir /etc/swh

USER swh
WORKDIR /opt/swh

COPY --chown=swh:swh requirements-frozen.txt /opt/swh

ENV PYTHONPATH=/opt/swh
ENV PATH=/opt/swh/.local/bin:$PATH

RUN /usr/local/bin/python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements-frozen.txt

# Install rustup and the default rust toolchain

ENV CARGO_HOME="/opt/swh/.cargo"
ENV RUSTUP_HOME="/opt/swh/.rustup"

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup-init.sh && \
  chmod +x /tmp/rustup-init.sh && \
  /tmp/rustup-init.sh -y && \
  rm /tmp/rustup-init.sh

ENV PATH="${CARGO_HOME}/bin:${PATH}"

# Install

RUN RUSTFLAGS="-C target-cpu=native" \
  cargo install --git https://gitlab.softwareheritage.org/swh/devel/swh-graph.git \
    --features grpc-server \
    swh-graph

ENV SWH_CONFIG_FILENAME=/etc/swh/config.yml
ENV PORT 5009
EXPOSE $PORT

COPY --chown=swh:swh entrypoint.sh /opt/swh
RUN chmod u+x /opt/swh/entrypoint.sh

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
