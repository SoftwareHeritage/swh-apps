ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

FROM ${base_image}:${base_image_version}

ARG user=swh
ARG workdir=/opt/${user}
ARG configdir=/etc/${user}

COPY --chmod=0644 requirements-frozen.txt ${workdir}
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt

COPY --chmod=0755 entrypoint.sh ${workdir}

USER ${user}
ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ENV STATSD_PORT=9125
ENV STATSD_HOST=prometheus-statsd-exporter
# STATSD_TAGS: scrubber_instance:<database>-<objecttype>-<id>
ENV STATSD_TAGS=
# OBJECT_TYPE: The type of object to run on (origin/origin-visit/...)
ENV OBJECT_TYPE=
# PARTITION_COUNT: ^2 number of ranges to split the object
ENV PARTITION_COUNT=
# FIRST_PARTITION: The first partition id to check (inclusive)
ENV FIRST_PARTITION=
# LAST_PARTITION: The last partition id to check (exclusive)
ENV LAST_PARTITION=

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
