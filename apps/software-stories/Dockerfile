FROM node:19-bullseye

RUN apt-get -y update && \
    apt-get -y upgrade && \
    npm install -g serve && \
    mkdir -p /opt/swh/swh-stories && \
    chown -R node:node /opt/swh

USER node
ENV NODE_OPTIONS=--openssl-legacy-provider
WORKDIR /opt/swh/swh-stories

COPY --chown=node:node entrypoint.sh /opt/swh

RUN chmod u+x /opt/swh/entrypoint.sh && \
    git clone https://github.com/ScienceStories/swh-stories.git /opt/swh/swh-stories && \
    git checkout 04168585b48edb77b3410cfe0e5e06af545bb18c && \
    rm package-lock.json && \
    npm install --no-audit && \
    npm run build

ENTRYPOINT "/opt/swh/entrypoint.sh"
