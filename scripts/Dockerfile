# build-deps container to call scripts/generate-frozen-requirements.txt on an
# application (e.g. swh-loader-svn, swh-loader-git, ...)
FROM python:3.10-bullseye
ARG userid=1000
ARG groupid=1000

RUN addgroup --gid $groupid swh && \
    useradd --gid $groupid --uid $userid -m -d /opt/swh swh

# First install the runtime deps of all swh applications
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y \
      # journal (kafka)
      librdkafka-dev \
      # svn loader (subvertpy)
      libsvn-dev libapr1-dev libaprutil1-dev \
      libpython3-dev \
      libpq-dev \
      # objstorage deps (winery)
      libsystemd-dev \
      pkg-config \
      # swh lister's dependency on rpy2 need this
      r-base-dev \
    && \
    apt clean

RUN install -d -o swh /opt/scripts/

USER swh
WORKDIR /opt/swh

RUN pip install -U pip setuptools wheel
ENV PATH=$PATH:/opt/swh/.local/bin

COPY --chown=$userid:$groupid --chmod=0644 requirements.txt /opt/scripts/
RUN pip install -r /opt/scripts/requirements.txt

# This expects the /src/ to be mounted on swh-apps repository folder at runtime
ENV SWH_APPS_DIR=/src/apps

COPY --chown=$userid:$groupid --chmod=0755 app_manager.py /opt/scripts/

ENTRYPOINT [ "/opt/scripts/app_manager.py" ]
