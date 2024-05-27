# Deeply inspired from the Dockerfile of the swh-graphql project
FROM python:3.10-bullseye
# swhstorage user is 1005 on current static server (saam, ...). To avoid permission
# changes on PB of data, we'll use the same uid/gid pair
ARG UID=1005
ARG GID=1005
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev librdkafka-dev && \
    apt clean && \
    addgroup --gid $GID swh && \
    useradd --gid $GID --uid $UID -m -d /opt/swh swh && \
    mkdir /etc/swh

USER swh
WORKDIR /opt/swh

COPY --chown=swh:swh requirements-frozen.txt /opt/swh
COPY --chown=swh:swh entrypoint.sh /opt/swh

ENV PYTHONPATH=/opt/swh
ENV PATH=/opt/swh/.local/bin:$PATH

RUN chmod u+x /opt/swh/entrypoint.sh && \
    /usr/local/bin/python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements-frozen.txt && \
    pip install gunicorn

ENV SWH_CONFIG_FILENAME=/etc/swh/config.yml
ENV PORT 5003
EXPOSE $PORT
ENV THREADS 2
ENV WORKERS 8
ENV TIMEOUT 3600

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
