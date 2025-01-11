# Quick Setup Guide

The following process utilises docker containers to quickly provision a Wireguard VPN server.

An additional container is created alongside Wireguard called [Traefik](https://doc.traefik.io/traefik/), which is a open-source application proxy. It allows for flexibility, visualisation and control when choosing to expand on the current configuration.

## Information Gathering

Have the following known before proceeding.

- User account used to run the server.
- List of user(s) which will be VPN users (not essential, however less touches required later).
- Domain name DNS record for the server.

## Basic Setup

### Linux

1. Clone repository at your proposed server location.

    ```
    git clone https://github.com/bodane/vpn-wireguard.git && cd vpn-wireguard
    ```

1. Run `vanilla-setup.sh`.

   This script will:

   - Create a new user.
     - User will manage the VPN server components.
   - Add user to sudo group.
   - Install git, nano, and Docker
   - Add user to Docker group.

1. Create your list of VPN users.

   - Edit your `.env` file.
     - Update `NODE_HOSTNAME=my.domain.name` and `SERVER_CNAME_NAMESPACE=my.domain.name` with your server DNS record.
     - Update `PEERS` with your list of users, separated by commas.

   **NOTE**: The user list can be updated later if not known and the container re-created without user impact. Will however disconnect users during this operation.

1. Build your Wireguard VPN server with one command.

   ```
   docker compose up -d
   ```

## Add additional VPN users

1. Edit existing list of VPN users.

     - Update `.env` file with your list of users.
       - Add or remove users.
       - All must be separated by commas.

1. Start up a new container. All past changes will persist due to the docker volumes being used.

    This will setup new user VPN profiles while also leaving any present peers in-place.

   ```
   docker compose down
   docker compose up -d
   ```

## Basic Firewalling

Configure some basic 
|     Port     |  Server-Side or Cloud Service Inbound Policy    |
|--------------|-------------------------------------------------|
| TCP 22       | Server admin. Whitelist admin source IP's only  |
| TCP 80, 443  | Traefik admin. Whitelist admin source IP's only |
| UDP 51820    | Wireguard VPN                                   |
| ANY          | Block and Log (if possible)                     |

## User Profile Location

While in the `vpn-wireguard` folder path. The user VPN profiles are located in the `config` folder path.

## Optional Improvements

There are almost an infinite amount of configurations, however one great addition could be that we do block unsafe domains or known malicous domain names being accessed by users.

The basic script and Corefile included will assist with this configuration. We'll also use a couple of known public threat intel feeds to develop our own blacklist for use locally. How it works is, if the user were to perform a DNS query to resolve an unsafe domain, the CoreDNS server returns a DNS response of `0.0.0.0` back to the user device for the target domain. This effectively prevents a request taking place to the remote host.

### Linux

1. Run `blacklist.sh` on your server endpoint. A `blacklist.txt` file will be created locally.

    ```
    ./optional-config/blacklist.sh
    ```

1. Backup your current Corefile, place it in a easy to find path related to CoreDNS, and update the CoreDNS file to reference the newly created `blacklist.txt` file.

    ```
    cp config/coredns/Corefile config/coredns/Corefile.bak
    cp optional-config/Corefile config/coredns/Corefile
    cp blacklist.txt config/coredns/blacklist.txt
    ```

1. Restart your Wireguard VPN server to have the changes all take effect.

   ```
   docker restart lthn-vpn-wireguard-1
   ```

## Further improvements for consideration.

- Creating a cron schedule or similar to maintain a better active list of unsafe domains.


