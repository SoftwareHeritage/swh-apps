# Deeply inspired from the Dockerfile of the swh-graph project
FROM python:3.11-bookworm

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
