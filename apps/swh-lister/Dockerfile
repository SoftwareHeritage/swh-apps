ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

FROM softwareheritage/maven-index-exporter:v0.4.1 AS maven_index_exporter_image
FROM ${base_image}:${base_image_version}

ARG user=swh
ARG workdir=/opt/${user}
ARG configdir=/etc/${user}

USER root
RUN apt-get update && \
    apt-get install -y libsystemd-dev opam libsvn-dev \
        postgresql openjdk-17-jre-headless && \
    apt-get clean

COPY --chmod=0644 requirements-frozen.txt ${workdir}
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt

COPY --chmod=0755 entrypoint.sh ${workdir}

COPY --from=maven_index_exporter_image /opt/maven-index-exporter /opt/maven-index-exporter

USER ${user}
ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ENV SWH_WORKER_INSTANCE=lister
ENV CONCURRENCY=1
ENV MAX_TASKS_PER_CHILD=1

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
