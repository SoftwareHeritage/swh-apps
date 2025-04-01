ARG REGISTRY=rcontainer-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

FROM rust:1.85-bookworm AS rust_build

# Build swh rust deps
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential libclang-dev \
      zstd protobuf-compiler default-jre && \
    apt-get clean

ARG REPO_DATASETS=https://gitlab.softwareheritage.org/swh/devel/swh-datasets.git
ARG TARGET_CPU=x86-64-v3

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

# RUN mkdir -p /srv/graph /srv/dataset
# RUN chown ${userid}:${groupid} /srv/graph /srv/dataset
# VOLUME /srv/graph /srv/dataset

ARG SRC_BIN=/usr/local/cargo/bin
COPY --from=rust_build ${SRC_BIN}/aggregate* ${SRC_BIN}/export* \
    ${SRC_BIN}/origin* ${SRC_BIN}/list-files* ${SRC_BIN}/popular* \
     /usr/local/bin/

COPY --chmod=0644 requirements-frozen.txt ${workdir}
COPY --chmod=0755 entrypoint.sh ${workdir}

USER ${user}
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt && uv pip install swh.export

USER ${user}
ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ARG LUIGI_DIRPATH=/tmp/luigid
ENV LUIGI_PATH_TO_PIDFILE=${LUIGI_DIRPATH}/pid
ENV LUIGI_PATH_TO_LOGDIR=${LUIGI_DIRPATH}/log
ENV LUIGI_PATH_TO_STATEFILE=${LUIGI_DIRPATH}/state
RUN mkdir -p ${LUIGI_PATH_TO_LOGDIR}

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
