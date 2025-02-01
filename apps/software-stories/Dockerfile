FROM node:19-bullseye

RUN apt-get -y update && \
    apt-get -y upgrade && \
    npm install -g serve && \
    mkdir -p /opt/swh/swh-stories && \
    chown -R node:node /opt/swh

USER node
ENV NODE_OPTIONS=--openssl-legacy-provider
WORKDIR /opt/swh/swh-stories

RUN git clone https://github.com/ScienceStories/swh-stories.git /opt/swh/swh-stories && \
    npm install --no-audit && \
    npm run build

COPY --chown=node:node entrypoint.sh /opt/swh
RUN chmod u+x /opt/swh/entrypoint.sh

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
