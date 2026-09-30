#
# Build
#
FROM python:3.14-slim AS build

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/app/.venv

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y git npm && \
    rm -rf /var/lib/apt/lists/*
RUN useradd --home /app --create-home --shell /bin/bash dataportal
USER dataportal

RUN git clone https://gitlab.softwareheritage.org/swh/devel/swh-dataportal /app/swh-dataportal
WORKDIR /app/swh-dataportal

RUN npm ci
ENV PATH="/app/node_modules/.bin:/app/.venv/bin:$PATH"
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Generate documentation from the repository
# TODO: Make the html documentation generation an artifact to download
# from jenkins (see swh-docs's publish step build)
RUN pip install --upgrade pip uv && \
    uv pip install /app/swh-dataportal && \
    swh dataportal build

#
# Runtime
#
FROM nginx:alpine
COPY --from=build /app/swh-dataportal/output/html/ \
    /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
