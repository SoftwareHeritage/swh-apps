# Deeply inspired from the Dockerfile of the swh-graph project
ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
# Depends on loader-package to inherit its runtime dependencies
ARG base_image=${REGISTRY}loader_package
ARG base_image_version=latest

FROM ${REGISTRY}rsvndump-base:latest AS rsvndump_image

FROM ${base_image}:${base_image_version}
COPY --from=rsvndump_image /usr/local/bin/rsvndump /usr/local/bin/rsvndump

ARG user=swh
ARG workdir=/opt/${user}

USER root
RUN apt-get update && \
    apt-get install -y libsvn-dev libapr1-dev libaprutil1-dev subversion \
      cvs bzr opam patool mercurial && \
    apt-get clean

COPY --chmod=0644 requirements-frozen.txt ${workdir}
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt

COPY --chmod=0755 entrypoint.sh ${workdir}

USER ${user}

ENTRYPOINT [ "/opt/swh/entrypoint.sh" ]
