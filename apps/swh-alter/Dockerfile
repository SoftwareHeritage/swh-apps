FROM python:3.11-bullseye

ARG user=swh
ARG workdir=/opt/${user}

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev librdkafka-dev libsystemd-dev \
      netcat-openbsd jq dnsutils \
      sed curl telnet host emacs-nox vim postgresql-client && \
    apt clean && \
    addgroup --gid 1000 ${user} && \
    useradd --gid 1000 --uid 1000 -m -d ${workdir} ${user} && \
    mkdir /etc/${user}

USER ${user}
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

COPY --chown=${user}:${user} requirements-frozen.txt ${workdir}

ENV PYTHONPATH=${workdir}
ENV PATH=${workdir}/.local/bin:$PATH

RUN /usr/local/bin/python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements-frozen.txt

COPY --chown=${user}:${user} entrypoint.sh ${workdir}
RUN chmod u+x ${workdir}/entrypoint.sh

ENTRYPOINT "/opt/swh/entrypoint.sh"
