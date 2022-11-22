# build-deps container to call scripts/generate-frozen-requirements.txt on an
# application (e.g. swh-loader-svn, swh-loader-git, ...)
FROM python:3.10-bullseye

# First install the runtime deps of all swh applications
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y \
      # objstorage deps (winery)
      libcmph-dev \
      # journal (kafka)
      librdkafka-dev \
      # svn loader (subvertpy)
      libsvn-dev libapr1-dev libaprutil1-dev \
      libpq-dev \
      python3-venv \
    && \
    apt clean

RUN mkdir -p /opt/scripts/
COPY common.py /opt/scripts/
COPY generate-frozen-requirements /opt/scripts/
RUN chmod +x /opt/scripts/generate-frozen-requirements

# This expects the /src/ to be mounted on swh-apps repository folder at runtime
ENV SWH_APPS_DIR=/src/apps

WORKDIR /opt/scripts
ENTRYPOINT [ "./generate-frozen-requirements" ]
