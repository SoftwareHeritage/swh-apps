FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y gettext-base curl awscli && \
    apt-get clean
