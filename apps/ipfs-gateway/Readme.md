# IPFS swh gateway

## Usage

To be able to retrieve the swh contents, the gateway uses a private SWH api endpoint.
To do so, an SWH api token must be configured in the gateway configuration.

- Bootstrap the gateway
```
    mkdir /srv/ipfs  # This is where the ipfs data will be stored
    docker run --rm -ti -v /tmp/test:/data/ipfs --user $UID \
        container-registry.softwareheritage.org/swh/infra/swh-apps/ipfs-gateway \
        initipfs init -e -p swhbridge
```
WARN: ignore the ipld error (https://github.com/ipfs/kubo/issues/9155)

- Edit the config file `/srv/ipfs/config` and search the Datastore.Spec.mounts section.
- In the swhbridge child, add an `auth-token` entry:
```json
{
    Datastore {
        Spec {
            "mounts": [
                {
                "child": {
                    "type": "swhbridge",
                    "auth-token: "<replace by the very long token>"
                },
            ]
        }
    }
}
```

- Start the gateway with:
```
    docker run -d --name ipfs-gateway -p 5001:5001 -p 4001:4001/udp \
        -v /srv/ipfs:/data/ipfs \
        container-registry.softwareheritage.org/swh/infra/swh-apps/ipfs-gateway
```

The gateway detects the available interfaces and tries to guess its public ip address.
```
Swarm listening on /ip4/127.0.0.1/tcp/4001
Swarm listening on /ip4/127.0.0.1/udp/4001/quic
Swarm listening on /ip4/172.17.0.2/tcp/4001
Swarm listening on /ip4/172.17.0.2/udp/4001/quic
Swarm listening on /p2p-circuit
Swarm announcing /ip4/127.0.0.1/tcp/4001
Swarm announcing /ip4/127.0.0.1/udp/4001/quic
Swarm announcing /ip4/172.17.0.2/tcp/4001
Swarm announcing /ip4/172.17.0.2/udp/4001/quic
Swarm announcing /ip4/1.2.3.4/udp/4001/quic   <------ the detected public address
API server listening on /ip4/0.0.0.0/tcp/5001
WebUI: http://0.0.0.0:5001/webui
Gateway (readonly) server listening on /ip4/0.0.0.0/tcp/8080
```

If the annouces are not correct, it can be fixed in the configuration, the section `Adresses.Announce` and `Addresses.AppendAnnounce`

**To be reachable from the internet, the port 4001 must be routed to the container**

## Testing

Once the gateway is up and publicly reachable, it can be tested like this:
```
docker run -ti --name ipfs-client --rm ipfs/kubo
```
On another terminal:

```
docker exec client ipfs dag get \
    --output-codec=git-raw \
       f0178111494a9ed024d3859793618152ea559a168bbcbb5e2
```

For more details on the ipfs usage, check at the ipfs gateway main repository:
https://github.com/obsidiansystems/go-ipfs-swh-plugin.git
