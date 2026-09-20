#######
# build
#######
# TODO: use an swh repository if it becomes a permanent thing
ARG REPOSITORY=https://github.com/obsidiansystems/go-ipfs-swh-plugin.git
ARG GIT_HEAD=2380683e3309e2c5bb167dbbbcb50f71eed063bb # master at 2023-01-31

FROM debian:trixie as build

RUN apt update -y && apt dist-upgrade -y && apt install -y git nix

RUN mkdir /src && cd /src && \
    git clone --depth 1 https://github.com/obsidiansystems/go-ipfs-swh-plugin.git && \
    cd go-ipfs-swh-plugin && \
    git checkout $HEAD

RUN cd /src/go-ipfs-swh-plugin && \
    nix-build && \
    nix-store --export $(nix-store --query --requisites ./result) > ipfs.dump

# #############
# # final image
# #############

FROM debian:trixie

RUN apt update && apt dist-upgrade -y && apt install -y nix && apt clean

COPY --from=build  /src/go-ipfs-swh-plugin/ipfs.dump /tmp

# Install ipfs cli with the minimalist runtime dependencies set
RUN nix-store --import < /tmp/ipfs.dump && \
    update-alternatives  --install /usr/bin/ipfs  ipfs /nix/store/*ipfs*/bin/ipfs 1

RUN addgroup --gid 1000 ipfs && \
    useradd --gid 1000 --uid 1000 -m ipfs

USER ipfs
WORKDIR /home/ipfs

USER ipfs
WORKDIR /data/ipfs
ENV IPFS_PATH=/data/ipfs

# | true to ignore the empty directory error:
# https://github.com/ipfs/kubo/issues/9155
RUN ipfs init -e -p swhbridge || true && \
  ipfs config Addresses.API /ip4/0.0.0.0/tcp/5001 && \
  ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/8080

ENTRYPOINT [ "ipfs" ]
CMD ["daemon"]
