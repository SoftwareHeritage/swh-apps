FROM node:24-trixie

RUN apt-get -y update && \
    apt-get -y upgrade && \
    mkdir -p /opt/swh/swh-stories && \
    chown -R node:node /opt/swh && \
    apt-get clean

USER node

WORKDIR /opt/swh/swh-stories

RUN git clone https://github.com/ScienceStories/swh-stories.git /opt/swh/swh-stories && \
    npm install --no-audit && \
    npm run build

COPY --chown=node:node entrypoint.sh /opt/swh
RUN chmod u+x /opt/swh/entrypoint.sh

ENTRYPOINT ["/opt/swh/entrypoint.sh"]
