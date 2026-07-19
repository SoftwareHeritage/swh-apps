# -------------- Build stage --------------------
FROM debian:trixie AS downloader

ARG swh_docs_publish_job_id=lastStableBuild

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        unzip \ 
        wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Download the documentation archive from the Jenkins publish job.
RUN wget \
    -O archive.zip \
    "https://jenkins.softwareheritage.org/job/DDOC/job/publish/${swh_docs_publish_job_id}/artifact/*zip*/archive.zip"

# Extract the archive.
RUN unzip archive.zip

# ------------- Runtime stage ----------------------------

FROM nginx:alpine

# Remove the default nginx content.
RUN rm -rf /usr/share/nginx/html/*

# Copy the generated documentation.
COPY --from=downloader \
    /tmp/archive/swh-docs/docs/_build/html/ \
    /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]