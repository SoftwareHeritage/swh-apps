FROM python:3.10-bookworm

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y libcmph-dev netcat-openbsd jq && \
    apt clean && \
    addgroup --gid 1000 swh && \
    useradd --gid 1000 --uid 1000 -m -d /opt/swh swh

USER swh
WORKDIR /opt/swh

ENV PATH=/opt/swh/.local/bin:$PATH

RUN /usr/local/bin/python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements-frozen.txt

CMD [ "/bin/bash", "-i" ]
