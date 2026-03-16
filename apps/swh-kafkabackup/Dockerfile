ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

FROM ${base_image}:${base_image_version}

ARG user=swh
ARG workdir=/opt/${user}
ARG configdir=/etc/${user}
ARG RCLONE_VERSION=v1.73.2
ARG RCLONE_SHA256=2c6bc8e6ee23493907bdae2c599b00b9fcc2def7d1346211ce371323d14ac9d6

# Install rclone
USER root
RUN wget -O "/tmp/rclone.deb" \
        "https://github.com/rclone/rclone/releases/download/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-amd64.deb" \
    && echo "${RCLONE_SHA256} /tmp/rclone.deb" | sha256sum --check --status - \
    && dpkg -i /tmp/rclone.deb \
    && rm /tmp/rclone.deb

USER ${user}

COPY --chmod=0644 requirements-frozen.txt ${workdir}
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt

RUN mkdir ${workdir}/.ssh

COPY --chmod=0755 entrypoint.sh ${workdir}

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
