FROM python:3.10-bullseye

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev  \
      git && \
    apt clean && \
    addgroup --gid 1000 swh && \
    useradd --gid 1000 --uid 1000 -m -d /opt/swh swh && \
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
ENV PORT 5005
EXPOSE $PORT
ENV THREADS 4
ENV WORKERS 2
ENV TIMEOUT 3600

ENTRYPOINT "/opt/swh/entrypoint.sh"
