ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

FROM ${base_image}:${base_image_version}

ARG install_user=swh
ARG workdir=/opt/${install_user}
ARG configdir=/etc/${user}

ARG run_userid=1005
ARG run_groupid=1005
ARG run_user=swhstorage
ARG home_user=/opt/${run_user}

USER root
COPY --chmod=0644 requirements-frozen.txt ${workdir}
RUN --mount=type=cache,target=.cache,uid=1005,gid=1005 \
    uv pip sync requirements-frozen.txt

COPY --chmod=0755 entrypoint.sh ${workdir}

RUN addgroup --gid ${run_userid} ${run_user} && \
    useradd --gid ${run_groupid} --uid ${run_userid} -m -d ${home_user} ${run_user}

USER ${run_user}

ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ENV PORT 5003
EXPOSE $PORT
ENV THREADS 2
ENV WORKERS 8
ENV TIMEOUT 3600

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
