# Deeply inspired from the Dockerfile of the swh-graph project
FROM python:3.11-bookworm

ARG userid=1000
ARG groupid=1000
ARG user=swh
ARG workdir=/opt/${user}
ARG venv=${workdir}/venv
ARG configdir=/etc/${user}

RUN echo deb http://deb.debian.org/debian/ bullseye-backports main \
      > /etc/apt/sources.list.d/backports.list
RUN echo deb [trusted=yes] https://debian.softwareheritage.org/ bullseye-swh main  \
      > /etc/apt/sources.list.d/softwareheritage.list

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev librdkafka-dev \
      fossology-nomossa && \
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
ENV SWH_WORKER_INSTANCE=indexer
ENV CONCURRENCY=1
ENV MAX_TASKS_PER_CHILD=1

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
