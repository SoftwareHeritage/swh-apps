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

ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ENV PORT=5005
EXPOSE $PORT
ENV THREADS=4
ENV WORKERS=2
ENV TIMEOUT=3600

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
