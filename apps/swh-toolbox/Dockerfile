FROM python:3.10-bullseye

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev librdkafka-dev libsystemd-dev \
      opam git r-base-dev netcat-openbsd jq dnsutils \
      sed curl telnet host emacs-nox vim postgresql-client-13 \
      subversion libsvn-dev && \
    apt clean && \
    addgroup --gid 1000 swh && \
    useradd --gid 1000 --uid 1000 -m -d /opt/swh swh && \
    mkdir /etc/swh

# Install svix cli
RUN wget -q https://github.com/svix/svix-cli/releases/download/v0.21.1/svix_0.21.1_linux_amd64.deb && \
    dpkg -i svix_0.21.1_linux_amd64.deb

RUN wget -q https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_linux_amd64.deb && \
    dpkg -i grpcurl_1.9.1_linux_amd64.deb

USER swh
RUN /usr/local/bin/python -m venv /opt/swh/venv
WORKDIR /opt/swh

ENV PYTHONPATH=/opt/swh/venv
ENV PATH=/opt/swh/venv/bin:$PATH

RUN python -m pip install uv
COPY --chown=swh:swh requirements-frozen.txt /opt/swh
RUN uv pip sync --no-cache requirements-frozen.txt

COPY --chown=swh:swh entrypoint.sh /opt/swh
RUN chmod u+x /opt/swh/entrypoint.sh

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
