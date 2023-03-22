# Deeply inspired from the Dockerfile of the swh-graph project
FROM python:3.10-bullseye

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev librdkafka-dev && \
    apt clean && \
    addgroup --gid 1000 swh && \
    useradd --gid 1000 --uid 1000 -m -d /opt/swh swh && \
    mkdir /etc/swh

USER swh
WORKDIR /opt/swh

COPY --chown=swh:swh requirements-frozen.txt /opt/swh

ENV PYTHONPATH=/opt/swh
ENV PATH=/opt/swh/.local/bin:$PATH

RUN /usr/local/bin/python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements-frozen.txt

COPY --chown=swh:swh entrypoint.sh /opt/swh
RUN chmod u+x /opt/swh/entrypoint.sh

ENV SWH_CONFIG_FILENAME=/etc/swh/config.yml
ENV LOGLEVEL INFO
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

ENTRYPOINT "/opt/swh/entrypoint.sh"
