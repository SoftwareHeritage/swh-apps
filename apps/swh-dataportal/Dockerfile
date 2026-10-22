#
# Retrieve artifacts from the jenkins build
#
FROM debian:trixie-slim AS downloader

ARG swh_dataportal_publish_job_id=lastStableBuild

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/app/.venv

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      unzip \
      wget && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Download the documentation archive from the Jenkins publish job.
RUN wget \
    -O archive.zip \
    "https://jenkins.softwareheritage.org/job/swh-dataportal/job/master/${swh_dataportal_publish_job_id}/artifact/output/html/*zip*/html.zip"

# Extract the archive.
RUN unzip archive.zip

FROM nginx:alpine
# Remove the default nginx content.
RUN rm -rf /usr/share/nginx/html/*

# Copy the generated documentation.
COPY --from=downloader \
    /tmp/html/ \
    /usr/share/nginx/html/

# Runtime
#
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
