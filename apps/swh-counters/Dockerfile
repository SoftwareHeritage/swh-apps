ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

FROM ${base_image}:${base_image_version}

ARG user=swh
ARG workdir=/opt/${user}
ARG configdir=/etc/${user}

USER root
# retry command is used by the refresh-history cron job
# to ensure the rpc service is well up
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install retry && \
    apt-get clean

COPY --chmod=0644 requirements-frozen.txt ${workdir}
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt

COPY --chmod=0755 entrypoint.sh ${workdir}

USER ${user}
ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ENV PORT=5011
ENV MEMRAY_ENABLED=false
ENV MEMRAY_OPTIONS=
EXPOSE $PORT
ENV THREADS=2
ENV WORKERS=2
ENV TIMEOUT=3600

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
