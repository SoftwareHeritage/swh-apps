FROM pypy:3.11-bookworm

ARG userid=1000
ARG groupid=1000
ARG user=swh
ARG workdir=/opt/${user}
ARG venv=${workdir}/venv
ARG configdir=/etc/${user}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git sed \
      gzip lzip zstd cpio \
      less && \
    apt-get clean && \
    addgroup --gid ${userid} ${user} && \
    useradd --gid ${groupid} --uid ${userid} -m -d ${workdir} ${user} && \
    mkdir ${configdir}

USER ${user}
RUN python -m venv ${venv}
WORKDIR ${workdir}

ENV PYTHONPATH=${venv}
ENV PATH=${venv}/bin:$PATH

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ARG user=swh
ARG workdir=/opt/${user}
ARG configdir=/etc/${user}

USER root
RUN apt-get update && \
    apt-get install -y strace gdb && \
    apt-get clean

USER root
RUN apt-get update && \
    apt-get install -y libcmph-dev && \
    apt-get clean

COPY --chmod=0644 requirements-frozen.txt ${workdir}
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt

# Install dulwich in pure python mode to get PyPy JIT effects
RUN uv pip install --reinstall --no-binary dulwich \
    --config-setting global-option=--pure dulwich && rm -r /tmp/*

COPY --chmod=0755 entrypoint.sh ${workdir}

USER ${user}
ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ENV SWH_WORKER_INSTANCE=loader
ENV CONCURRENCY=1
ENV MAX_TASKS_PER_CHILD=1

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
