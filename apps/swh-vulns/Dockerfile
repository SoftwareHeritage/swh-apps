ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

ARG RUST_VERSION=1.96
ARG TARGET_CPU=x86-64-v3

FROM rust:${RUST_VERSION}-bookworm AS rust_build

ARG TARGET_CPU

# ... build swh-vulns rust deps
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential libclang-dev \
      zstd protobuf-compiler && \
    apt-get clean

# Install the grpc server binary
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    # Will build out of the latest release in crates.io (the default)
    RUSTFLAGS="-C target-cpu=${TARGET_CPU}" cargo install --locked \
        --all-features swh-vulns-grpc-server

FROM ${base_image}:${base_image_version}

ARG userid=1000
ARG groupid=1000
ARG user=swh
ARG workdir=/opt/${user}
ARG configdir=/etc/${user}

USER root
RUN apt-get update && \
    apt-get install -y zstd && \
    apt-get clean

RUN mkdir -p /srv/graph /srv/dataset
RUN chown ${userid}:${groupid} /srv/graph /srv/dataset
VOLUME /srv/graph /srv/dataset

COPY --chmod=0644 requirements-frozen.txt ${workdir}
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt

COPY --from=rust_build /usr/local/cargo/bin/swh-vuln* /usr/local/bin/
COPY --chmod=0755 entrypoint.sh ${workdir}

USER ${user}
ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ENV PORT=50161
EXPOSE $PORT

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
