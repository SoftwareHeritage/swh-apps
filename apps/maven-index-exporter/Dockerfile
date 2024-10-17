FROM adoptopenjdk/openjdk11:debian-jre

RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && apt-get upgrade -y && \
  apt-get install -y python3 python3-click python3-requests wget && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Download and install jars
RUN cd /opt && wget -q \
    https://github.com/javasoze/clue/releases/download/release-6.2.0-1.0.0/clue-6.2.0-1.0.0.jar
# coming out of https://github.com/javasoze/clue/releases/tag/release-6.2.0-1.0.0

RUN cd /opt && wget -q \
    https://repo1.maven.org/maven2/org/apache/maven/indexer/indexer-cli/6.0.0/indexer-cli-6.0.0.jar
# FIXME: Retrieve https://repo1.maven.org/maven2/org/apache/maven/indexer/indexer-cli/6.0.0/indexer-cli-6.0.0.jar.sha1
# indexer-cli-6.0.0.jar.sha1: eeb98596b7fed4aa13fa13ecafcbb843ef8ab697
# Copy index extraction script

COPY run_full_export.py /opt/
COPY extract_indexes.sh /opt/

RUN mkdir /work/ && chmod +x /opt/extract_indexes.sh
WORKDIR /work/

ENV MVN_IDX_EXPORTER_BASE_URL=http://clojars.org/repo/
ENV MVN_IDX_EXPORTER_WORK_DIR=/work
ENV MVN_IDX_EXPORTER_PUBLISH_DIR=/publish

CMD ["python3", "/opt/run_full_export.py"]
