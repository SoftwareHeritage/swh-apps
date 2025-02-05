FROM python:3.10-bullseye

ARG userid=1000
ARG groupid=1000
ARG user=swh
ARG workdir=/opt/${user}
ARG venv=${workdir}/venv
ARG configdir=/etc/${user}

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y gdb strace && \
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
ENV SWH_EXTRA_CLI_OPTIONS=""

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
