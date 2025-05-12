ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

# Whether to install as usual from the latest release (crates.io & pypi.org) or from
# swh-graph's git repository (either latest commit, or a specific commit). The context
# is sometimes swh-graph cannot compile rust binaries due to some unreleased
# dependencies in crates.io (e.g. webgraph-rs). This build argument allows to bypass
# such issue by directly specifying either:
# - tag: the default if not specified
# - dev: latest default branch's commit
# - $commit: a specific swh-graph's git commit
# This will then compiles and installs the rust binaries to the required version. Same
# goes for the python module's version.
ARG GRAPH_SOURCE_VERSION=tag
ARG RUST_VERSION=1.85

FROM rust:${RUST_VERSION}-bookworm AS rust_build

ARG GRAPH_SOURCE_VERSION=$GRAPH_SOURCE_VERSION

# ... build swh-graph rust deps
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y build-essential libclang-dev \
      zstd protobuf-compiler default-jre && \
    apt-get clean

# Install the full-fledged swh-graph binaries
# This will be reused by other images (see datasets)
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    if [ "${GRAPH_SOURCE_VERSION}" = "tag" ]; then \
        # Will build out of the latest release in crates.io (the default)
        RUSTFLAGS="-C target-cpu=native" cargo install --locked \
            --all-features swh-graph swh-graph-grpc-server; \
    elif [ "${GRAPH_SOURCE_VERSION}" = "dev" ]; then \
        # Will build out of the latest commit from the repository
        RUSTFLAGS="-C target-cpu=native" cargo install --locked \
            --git https://gitlab.softwareheritage.org/swh/devel/swh-graph.git \
            --all-features swh-graph swh-graph-grpc-server; \
    else \
        # Assumes GRAPH_SOURCE_VERSION is a commit
        RUSTFLAGS="-C target-cpu=native" cargo install --locked \
            --git https://gitlab.softwareheritage.org/swh/devel/swh-graph.git \
            --rev ${GRAPH_SOURCE_VERSION} \
            --all-features swh-graph swh-graph-grpc-server; \
    fi

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

ARG GRAPH_SOURCE_VERSION=$GRAPH_SOURCE_VERSION

RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    if [ "${GRAPH_SOURCE_VERSION}" = "tag" ]; then \
        # nothing to do (already done by the uv pip sync earlier)
        echo ; \
    elif [ "${GRAPH_SOURCE_VERSION}" = "dev" ]; then \
        # Will install the current associted python module swh-graph's latest master
        uv pip install git+https://gitlab.softwareheritage.org/swh/devel/swh-graph.git; \
    else \
        # Will install the current associted python module swh-graph's commit version
        uv pip install git+https://gitlab.softwareheritage.org/swh/devel/swh-graph.git@${GRAPH_SOURCE_VERSION}; \
    fi

COPY --from=rust_build /usr/local/cargo/bin/swh-graph* /usr/local/bin/
COPY --chmod=0755 entrypoint.sh ${workdir}

USER ${user}
ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ENV PORT=5009
EXPOSE $PORT

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
