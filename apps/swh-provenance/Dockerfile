ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

ARG TARGET_CPU=x86-64-v3
FROM rust:1.88-bookworm AS rust_build

# ... build swh-graph rust deps
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential libclang-dev \
      zstd protobuf-compiler default-jre && \
    apt-get clean

ARG TARGET_CPU=${TARGET_CPU}
# Compile and install swh-graph feature swh-graph-grpc-serve.
# Note that we compile ^ with the set of cpu instructions supported by most
# machines in our infrastructure
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
  RUSTFLAGS="-C target-cpu=${TARGET_CPU}" \
  cargo install swh-provenance --locked

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

COPY --chmod=0644 requirements-frozen.txt ${workdir}
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt

COPY --chmod=0755 entrypoint.sh ${workdir}
COPY --from=rust_build /usr/local/cargo/bin/swh-provenance* /usr/local/bin/

RUN mkdir -p /srv/dataset
RUN chown ${userid}:${groupid} /srv/dataset
VOLUME /srv/dataset

USER ${user}
ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
# Default to be a rpc service
ENV PORT=5014
ENV PROVENANCE_TYPE="rpc"
# Possible other value for grpc kind
# ENV PORT 50141
# ENV PROVENANCE_TYPE "grpc"
EXPOSE $PORT
# For rpc type, this maps directly to gunicorn env variables
ENV WORKERS=8
ENV THREADS=2
ENV TIMEOUT=3600

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
