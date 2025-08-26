ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

FROM ${base_image}:${base_image_version}

ARG user=swh
ARG workdir=/opt/${user}
ARG configdir=/etc/${user}

USER root
# As per [0], bullseye-backports reached eol
# [0] https://backports.debian.org/news/bullseye_backports_discontinued/
# RUN echo deb http://deb.debian.org/debian/ bullseye-backports main \
#       > /etc/apt/sources.list.d/backports.list
RUN echo deb [trusted=yes] https://debian.softwareheritage.org/ bullseye-swh main  \
      > /etc/apt/sources.list.d/softwareheritage.list

RUN apt-get update && \
    apt-get install -y fossology-nomossa && \
    apt-get clean

COPY --chmod=0644 requirements-frozen.txt ${workdir}
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt

COPY --chmod=0755 entrypoint.sh ${workdir}

USER ${user}
ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ENV SWH_WORKER_INSTANCE=indexer
ENV CONCURRENCY=1
ENV MAX_TASKS_PER_CHILD=1

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
