ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

ARG userid=1000
ARG groupid=1000
ARG user=swh
ARG workdir=/opt/${user}
ARG configdir=/etc/${user}

FROM rust:1.80-bookworm AS rust_build

# ... build swh-graph rust deps
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential libclang-dev \
      zstd protobuf-compiler default-jre && \
    apt-get clean

# Install swh-graph feature swh-graph-grpc-serve
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
  RUSTFLAGS="-C target-cpu=native" \
  cargo install swh-graph swh-graph-grpc-server

FROM ${base_image}:${base_image_version}

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

COPY --from=rust_build /usr/local/cargo/bin/swh-graph* /usr/local/bin/
COPY --chmod=0755 entrypoint.sh ${workdir}

USER ${user}
ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ENV PORT 5009
EXPOSE $PORT

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
