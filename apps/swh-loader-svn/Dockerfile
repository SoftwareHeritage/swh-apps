# ARG REGISTRY=container-registry.softwareheritage.org/infra/swh-apps/
ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG RSVNDUMP=/usr/local/bin/rsvndump

FROM ${REGISTRY}rsvndump-base:latest AS rsvndump_image
FROM python:3.11-bookworm
COPY --from=rsvndump_image ${RSVNDUMP} ${RSVNDUMP}

ARG userid=1000
ARG groupid=1000
ARG user=swh
ARG workdir=/opt/${user}
ARG venv=${workdir}/venv
ARG configdir=/etc/${user}

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev librdkafka-dev && \
    apt clean && \
    addgroup --gid ${userid} swh && \
    useradd --gid ${groupid} --uid ${userid} -m -d ${workdir} ${user} && \
    mkdir ${configdir}

USER swh
RUN python -m venv ${venv}
WORKDIR ${workdir}

ENV PYTHONPATH=${venv}
ENV PATH=${venv}/bin:$PATH

RUN python -m pip install uv
COPY --chown=${userid}:${groupid} requirements-frozen.txt ${workdir}
RUN uv pip sync --no-cache requirements-frozen.txt

COPY --chown=${userid}:${groupid} entrypoint.sh ${workdir}
RUN chmod u+x ${workdir}/entrypoint.sh

ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ENV SWH_WORKER_INSTANCE=loader
ENV CONCURRENCY=1
ENV MAX_TASKS_PER_CHILD=1

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
