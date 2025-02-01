# Deeply inspired from the Dockerfile of the swh-graphql project
FROM python:3.10-bullseye

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libsystemd-dev pkg-config && \
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
ENV PORT 5003
EXPOSE $PORT
# Winery is not designed to be thread safe
# So the number of threads per workers must be 1
#ENV THREADS 1
ENV WORKERS 8
ENV TIMEOUT 3600

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
