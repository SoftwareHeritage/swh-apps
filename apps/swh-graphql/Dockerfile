# Deeply inspired from the Dockerfile of the swh-graph project
FROM python:3.10-bullseye

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev librdkafka-dev && \
    rm -rf /var/lib/dpkg && \
    addgroup --gid 1000 swh && \
    useradd --gid 1000 --uid 1000 -m -d /opt/graphql swh && \
    mkdir /etc/swh

USER swh
WORKDIR /opt/graphql

COPY --chown=swh:swh requirements-frozen.txt /opt/graphql
COPY --chown=swh:swh entrypoint.sh /opt/graphql

ENV PYTHONPATH=/opt/graphql
ENV PATH=/opt/graphql/.local/bin:$PATH

RUN chmod u+x /opt/graphql/entrypoint.sh && \
    /usr/local/bin/python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements-frozen.txt && \
    pip install gunicorn

ENV SWH_CONFIG_FILENAME=/etc/swh/config.yml
ENV PORT 5013
EXPOSE $PORT
ENV THREADS 4
ENV WORKERS 2
ENV LOG_LEVEL INFO
ENV TIMEOUT 3600

ENTRYPOINT "/opt/graphql/entrypoint.sh"
