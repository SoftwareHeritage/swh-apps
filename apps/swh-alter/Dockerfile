ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}swh-base
ARG base_image_version=latest

FROM ${base_image}:${base_image_version}

ARG user=swh
ARG workdir=/opt/${user}

USER root
RUN apt-get update && \
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
    apt-get clean

COPY --chmod=0644 requirements-frozen.txt ${workdir}
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt

USER ${user}
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
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
  cargo install rage

COPY --chmod=0755 entrypoint.sh ${workdir}

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
