ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

FROM ${base_image}:${base_image_version}

ARG user=swh
ARG workdir=/opt/${user}
ARG configdir=/etc/${user}

USER root
RUN apt-get update && \
    apt-get install -y libsystemd-dev pkg-config && \
    apt-get clean

COPY --chmod=0644 requirements-frozen.txt ${workdir}
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt

COPY --chmod=0755 entrypoint.sh ${workdir}

USER ${user}
ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ENV PORT 5003
EXPOSE $PORT
# Winery is not designed to be thread safe
# So the number of threads per workers must be 1
#ENV THREADS 1
ENV WORKERS 8
ENV TIMEOUT 3600

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
