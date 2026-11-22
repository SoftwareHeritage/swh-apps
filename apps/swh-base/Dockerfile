FROM python:3.14-bookworm

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

# Include winery TLS certificates in the system CA bundle
COPY --chmod=0644 *.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Make sure that requests uses the system CA bundle instead of the bundle shipped by certifi
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

USER ${user}
RUN python -m venv ${venv}
WORKDIR ${workdir}

ENV PYTHONPATH=${venv}
ENV PATH=${venv}/bin:$PATH

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
