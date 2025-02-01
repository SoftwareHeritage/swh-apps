# ARG REGISTRY=container-registry.softwareheritage.org/infra/swh-apps/
ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG RSVNDUMP=/usr/local/bin/rsvndump

FROM ${REGISTRY}rsvndump-base:latest AS rsvndump_image
FROM python:3.10-bullseye
COPY --from=rsvndump_image ${RSVNDUMP} ${RSVNDUMP}

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev librdkafka-dev \
    subversion libsvn-dev && \
    apt clean && \
    addgroup --gid 1000 swh && \
    useradd --gid 1000 --uid 1000 -m -d /opt/swh swh && \
    mkdir /etc/swh

USER swh
RUN /usr/local/bin/python -m venv /opt/swh/venv
WORKDIR /opt/swh

ENV PYTHONPATH=/opt/swh/venv
ENV PATH=/opt/swh/venv/bin:$PATH

RUN python -m pip install uv
COPY --chown=swh:swh requirements-frozen.txt /opt/swh
RUN uv pip sync --no-cache requirements-frozen.txt

COPY --chown=swh:swh entrypoint.sh /opt/swh
RUN chmod u+x /opt/swh/entrypoint.sh

ENV SWH_CONFIG_FILENAME=/etc/swh/config.yml
ENV SWH_WORKER_INSTANCE=loader
ENV CONCURRENCY=1
ENV MAX_TASKS_PER_CHILD=1

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
