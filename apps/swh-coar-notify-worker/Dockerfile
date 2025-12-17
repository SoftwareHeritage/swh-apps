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
ENV DJANGO_SETTINGS_MODULE=swh.coarnotify.settings.production
ENV SWH_MAIN_PACKAGE=swh.coarnotify
ENV SWH_WORKER_INSTANCE=coarnotify
ENV CONCURRENCY=1
ENV MAX_TASKS_PER_CHILD=5

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
