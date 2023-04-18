# Deeply inspired from the Dockerfile of the swh-storage project
FROM python:3.10-bullseye

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev librdkafka-dev && \
    apt clean && \
    addgroup --gid 1000 swh && \
    useradd --gid 1000 --uid 1000 -m -d /srv/swh swh && \
    mkdir -p /etc/softwareheritage /var/log/softwareheritage/webapp && \
    chown swh:swh /var/log/softwareheritage/webapp

USER swh
WORKDIR /srv/swh

COPY --chown=swh:swh requirements-frozen.txt /srv/swh
COPY --chown=swh:swh entrypoint.sh /srv/swh

ENV PYTHONPATH=/srv/swh
ENV PATH=/srv/swh/.local/bin:$PATH

RUN chmod u+x /srv/swh/entrypoint.sh && \
    /usr/local/bin/python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements-frozen.txt && \
    pip install gunicorn

ENV SWH_CONFIG_FILENAME=/etc/softwareheritage/config.yml
ENV PORT 5004
EXPOSE $PORT
ENV THREADS 2
ENV WORKERS 2
ENV TIMEOUT 3600
ENV DJANGO_SETTINGS_MODULE swh.web.settings.production
ENV SWH_MAIN_PACKAGE swh.web

ENTRYPOINT ["/srv/swh/entrypoint.sh"]
