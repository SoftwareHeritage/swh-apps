FROM python:3.11-bookworm

ARG userid=1000
ARG groupid=1000
ARG user=swh
ARG workdir=/opt/${user}
ARG venv=${workdir}/venv
ARG configdir=/etc/${user}

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev librdkafka-dev libsystemd-dev \
      opam git r-base-dev netcat-openbsd jq dnsutils \
      sed curl telnet host emacs-nox vim postgresql-client-13 \
      subversion libsvn-dev && \
    apt clean && \
    addgroup --gid ${userid} ${user} && \
    useradd --gid ${groupid} --uid ${userid} -m -d ${workdir} ${user} && \
    mkdir ${configdir}

# Install svix cli
RUN wget -q https://github.com/svix/svix-cli/releases/download/v0.21.1/svix_0.21.1_linux_amd64.deb && \
    dpkg -i svix_0.21.1_linux_amd64.deb

RUN wget -q https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_linux_amd64.deb && \
    dpkg -i grpcurl_1.9.1_linux_amd64.deb

USER ${user}
RUN python -m venv ${venv}
WORKDIR ${workdir}

ENV PYTHONPATH=${venv}
ENV PATH=${venv}/bin:$PATH

RUN python -m pip install uv
COPY --chown=${userid}:${groupid} requirements-frozen.txt ${workdir}
RUN uv pip sync --no-cache requirements-frozen.txt

COPY --chown=${userid}:${groupid} entrypoint.sh ${workdir}
RUN chmod u+x ${workdir}/entrypoint.sh

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
