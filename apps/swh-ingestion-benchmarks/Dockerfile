ARG REGISTRY=container-registry.softwareheritage.org/swh/infra/swh-apps/
ARG base_image=${REGISTRY}base
ARG base_image_version=latest

FROM ${base_image}:${base_image_version}

ARG user=swh
ARG workdir=/opt/${user}
ENV LOCUST_LOCUSTFILE=${workdir}/ingestion-benchmarks/ingestion_benchmarks/objstorage/locustfile.py

USER root
RUN apt-get update && \
    apt-get install -y \
      netcat-openbsd jq dnsutils \
      curl emacs-nox vim git tmux && \
    apt-get clean

COPY --chmod=0644 requirements-frozen.txt ${workdir}

USER ${user}

RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip sync requirements-frozen.txt
RUN git clone https://gitlab.softwareheritage.org/swh/devel/experiments/ingestion-benchmarks
RUN --mount=type=cache,target=.cache,uid=1000,gid=1000 \
    uv pip install -e ingestion-benchmarks

COPY --chmod=0755 entrypoint.sh ${workdir}

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
