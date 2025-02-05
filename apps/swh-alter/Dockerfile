FROM python:3.11-bullseye

ARG userid=1000
ARG groupid=1000
ARG user=swh
ARG workdir=/opt/${user}
ARG venv=${workdir}/venv
ARG configdir=/etc/${user}

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y \
      curl \
      dnsutils \
      emacs-nox \
      host \
      jq \
      libcmph-dev \
      librdkafka-dev \
      libsystemd-dev \
      netcat-openbsd \
      postgresql-client \
      sed \
      strace \
      telnet \
      tmux \
      vim && \
    apt clean && \
    addgroup --gid ${userid} swh && \
    useradd --gid ${groupid} --uid ${userid} -m -d ${workdir} ${user} && \
    mkdir ${configdir}

USER swh
RUN python -m venv ${venv}
WORKDIR ${workdir}

ENV CARGO_HOME="${workdir}/.cargo"
ENV RUSTUP_HOME="${workdir}/.rustup"

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o /tmp/rustup-init.sh && \
  chmod +x /tmp/rustup-init.sh && \
  /tmp/rustup-init.sh -y && \
  rm /tmp/rustup-init.sh

ENV PATH="${CARGO_HOME}/bin:${PATH}"
# install rage (for swh-alter)

# Use the latest available version so we can detect if rage behavior has changed when
# testing swh-alter. Otherwise, this might only be detected when processing a
# takedown notice or restoring a bundle… which would not be a nice experience.
RUN cargo install rage

ENV PYTHONPATH=${venv}
ENV PATH=${venv}/bin:$PATH

RUN python -m pip install uv
COPY --chown=${userid}:${groupid} requirements-frozen.txt ${workdir}
RUN uv pip sync --no-cache requirements-frozen.txt

COPY --chown=${userid}:${groupid} entrypoint.sh ${workdir}
RUN chmod u+x ${workdir}/entrypoint.sh

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
