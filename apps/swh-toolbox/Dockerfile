ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
# Depends on loader-savecodenow to inherit its runtime dependencies
ARG base_image=${REGISTRY}loader-savecodenow
ARG base_image_version=latest

FROM ${base_image}:${base_image_version}

ARG user=swh

USER root
RUN apt-get update && \
    apt-get install -y \
      r-base-dev netcat-openbsd jq dnsutils \
      curl telnet host emacs-nox vim postgresql-client && \
    apt-get clean

# Install svix cli
RUN wget -q https://github.com/svix/svix-cli/releases/download/v0.21.1/svix_0.21.1_linux_amd64.deb && \
    dpkg -i svix_0.21.1_linux_amd64.deb

RUN wget -q https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_linux_amd64.deb && \
    dpkg -i grpcurl_1.9.1_linux_amd64.deb

COPY --chmod=0644 requirements-frozen.txt ${workdir}
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt

COPY --chmod=0755 entrypoint.sh ${workdir}

USER ${user}

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
