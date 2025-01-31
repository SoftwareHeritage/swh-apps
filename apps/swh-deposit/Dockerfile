# Deeply inspired from the Dockerfile of the swh-storage project
FROM python:3.10-bullseye

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev librdkafka-dev && \
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
ENV PORT 5006
EXPOSE $PORT
ENV THREADS 2
ENV WORKERS 2
ENV TIMEOUT 3600
ENV DJANGO_SETTINGS_MODULE swh.deposit.settings.production
ENV SWH_MAIN_PACKAGE swh.deposit

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
