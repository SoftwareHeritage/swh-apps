FROM python:3.10-bullseye
ARG UID=1000
ARG GID=1000
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

ENV PYTHONPATH=/opt/swh
ENV PATH=/opt/swh/.local/bin:$PATH

RUN /usr/local/bin/python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements-frozen.txt

COPY --chown=swh:swh entrypoint.sh /opt/swh
RUN chmod u+x /opt/swh/entrypoint.sh

ENV SWH_CONFIG_FILENAME=/etc/swh/config.yml
ENV PORT 5014
EXPOSE $PORT
ENV WORKERS 8
ENV THREADS 2
ENV TIMEOUT 3600

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
