# build-deps container to call various app_manager's subcommand on an swh application
# (e.g. generate-frozen-requirements, list-application, ...)
FROM python:3.14-bookworm

ARG userid=1000
ARG groupid=1000
ARG user=swh
ARG workdir=/opt/${user}
ARG venv=${workdir}/venv

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
    apt clean && \
    addgroup --gid ${groupid} ${user} && \
    useradd --gid ${groupid} --uid ${userid} -m -d ${workdir} ${user}

USER ${user}
RUN python -m venv ${venv}
WORKDIR ${workdir}

ENV PYTHONPATH=${venv}
ENV PATH=${venv}/bin:$PATH

RUN python -m pip install uv
COPY --chown=${userid}:${groupid} requirements.txt ${workdir}
RUN uv pip sync --no-cache requirements.txt

# This expects the /src/ to be mounted on swh-apps repository folder at runtime
ENV SWH_APPS_DIR=/src/apps

COPY --chown=${userid}:${groupid} app_manager.py ${workdir}
RUN chmod u+x ${workdir}/app_manager.py
ENTRYPOINT [ "/opt/swh/app_manager.py" ]
