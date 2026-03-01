ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

ARG TARGET_CPU=x86-64-v3

FROM ${REGISTRY}graph:latest as graph_build
FROM rust:1.86-bookworm AS rust_build

# Build swh rust deps
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential libclang-dev \
      zstd protobuf-compiler default-jre && \
    apt-get clean

ARG REPO_DATASETS=https://gitlab.softwareheritage.org/swh/devel/swh-datasets.git
ARG TARGET_CPU=${TARGET_CPU}

# Install swh-datasets rust applications
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    RUSTFLAGS="-C target-cpu=${TARGET_CPU}" \
    cargo install --locked --git ${REPO_DATASETS} \
      swh_graph_aggregate \
      swh_graph_contributions \
      swh_graph_file_names

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

# To ease debugging
# FIXME: Remove when this hits staging/production
RUN apt-get update && \
    apt-get install -y emacs-nox tree tmux && \
    apt-get clean

# To ease troubleshooting when some graph data is ko and the current graph code does not
# deal with it properly yet. We'll need to recompile the patched graph version
RUN apt-get update && \
    apt-get install -y build-essential libclang-dev \
      zstd protobuf-compiler && \
    apt-get clean

# RUN mkdir -p /srv/graph /srv/dataset
# RUN chown ${userid}:${groupid} /srv/graph /srv/dataset
# VOLUME /srv/graph /srv/dataset

ARG SRC_BIN=/usr/local/cargo/bin
ARG DST_BIN=/usr/local/bin

# Copy all swh-graph tools we built (in the rust_build image)
COPY --from=rust_build ${SRC_BIN}/aggregate* ${SRC_BIN}/export* \
    ${SRC_BIN}/origin* ${SRC_BIN}/list-files* ${SRC_BIN}/popular* \
    ${SRC_BIN}/swh-graph* \
    ${DST_BIN}

# Copy all rust tools as this may be needed for troubleshooting (and patching eventually
# the graph in the container)
COPY --from=rust_build ${SRC_BIN}/* ${DST_BIN}

# Copy all graph tools from the graph image
COPY --from=graph_build ${DST_BIN}/swh-graph-* ${DST_BIN}

COPY --chmod=0644 requirements-frozen.txt ${workdir}
COPY --chmod=0755 entrypoint.sh ${workdir}

USER ${user}
# To initialize the rust tooling
RUN rustup default stable

RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt && uv pip install swh.export

USER ${user}
ENV SWH_CONFIG_FILENAME=${configdir}/config.yml

ARG LUIGI_DIRPATH=/tmp/luigid
ENV LUIGI_CONFIG_PATH=/etc/luigi/luigi.cfg
ENV PORT=8082

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
