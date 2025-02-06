# Deeply inspired from the Dockerfile of the swh-graphql project
FROM python:3.11-bookworm

# swhstorage user is 1005 on current static server (saam, ...). To avoid permission
# changes on PB of data, we'll use the same uid/gid pair
ARG userid=1005
ARG groupid=1005
ARG user=swh
ARG workdir=/opt/${user}
ARG venv=${workdir}/venv
ARG configdir=/etc/${user}

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev librdkafka-dev && \
    apt clean && \
    addgroup --gid ${userid} ${user} && \
    useradd --gid ${groupid} --uid ${userid} -m -d ${workdir} ${user} && \
    mkdir ${configdir}

USER ${user}
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
ENV PORT 5003
EXPOSE $PORT
ENV THREADS 2
ENV WORKERS 8
ENV TIMEOUT 3600

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
