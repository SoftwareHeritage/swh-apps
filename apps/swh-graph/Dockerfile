FROM rust:1.80-bookworm AS rust_build
# ... build swh-graph rust deps
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y build-essential libclang-dev \
    zstd protobuf-compiler default-jre && \
    apt clean

# Install swh-graph feature swh-graph-grpc-serve
# TODO: Ensure the target-cpu is ok
RUN RUSTFLAGS="-C target-cpu=native" \
  cargo install swh-graph swh-graph-grpc-server

FROM python:3.10-bookworm

ARG userid=1000
ARG groupid=1000
ARG user=swh
ARG workdir=/opt/${user}
ARG venv=${workdir}/venv
ARG configdir=/etc/${user}

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y python3-pip \
      libcmph-dev librdkafka-dev zstd && \
    apt-get clean && \
    addgroup --gid ${userid} ${user} && \
    useradd --gid ${groupid} --uid ${userid} -m -d ${workdir} ${user} && \
    mkdir -p ${configdir}

RUN mkdir -p /srv/graph /srv/dataset
RUN chown ${userid}:${groupid} /srv/graph /srv/dataset
VOLUME /srv/graph /srv/dataset

USER ${user}
RUN python -m venv ${venv}
WORKDIR ${workdir}

ENV PYTHONPATH=${venv}
ENV PATH=${venv}/bin:$PATH

RUN python -m pip install uv
COPY --chown=${userid}:${groupid} requirements-frozen.txt ${workdir}
RUN uv pip sync --no-cache requirements-frozen.txt

COPY --from=rust_build /usr/local/cargo/bin/swh-graph* /usr/local/bin/
ENV SWH_CONFIG_FILENAME=${configdir}/config.yml
ENV PORT 5009
EXPOSE $PORT

COPY --chown=${userid}:${groupid} entrypoint.sh ${workdir}
RUN chmod u+x ${workdir}/entrypoint.sh

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
