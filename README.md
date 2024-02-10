# travis-nginx-proxy

In this scenario, an `nginx` container named `nginx-proxy` is initiated to emulate a proxy configuration. For practical deployment, you would substitute this with concrete `nginx` setup procedures that entail transferring SSL certificates and configuring reverse proxy parameters as required.

## Security Measures for Environment Variables

The process employs `DOMAIN` and `EMAIL` as environment variables. These should be securely configured within Travis CI's environment to prevent the disclosure of sensitive details.

## Inter-container Communication via Docker Networking 

The setup links containers through a Docker network, also named `nginx-proxy`, facilitating direct interaction between them. This direct communication channel is crucial for successfully completing the ACME challenge, particularly when SSL automation is implemented for deployments in actual operational environments.

## The Travis CI Config File

Here is the `.travis.yml` similar to the one I'm currently using privately. This repo is just to test fetching the `nginx-proxy` and make sure it's running, there's a full sample `travis.yml`:

```yaml
language: generic

services:
  - docker

env:
  global:
    - ACMESH_VERSION: "2.8.8" # Example version, adjust as needed
    - DOMAIN: "example.com" # Securely store your domain in Travis CI settings
    - EMAIL: "email@example.com" # Securely store your email in Travis CI settings

before_install:
  - |
    docker pull nginx
    docker pull neilpang/acme.sh
    docker network create nginx-proxy
    docker run -d --name nginx-proxy --net nginx-proxy -p 80:80 -p 443:443 nginx
    # Setup ACME client and obtain certificates
    docker run --rm  \
      -v "/etc/acme.sh":/acme.sh  \
      --net nginx-proxy \
      neilpang/acme.sh --issue -d ${DOMAIN} --standalone --email ${EMAIL}
    # Assuming certificate generation is successful, mount them into nginx
    docker run -d --name nginx-ssl --net nginx-proxy -p 443:443 \
      -v "/etc/acme.sh/${DOMAIN}":/etc/nginx/certs:ro \
      nginx

script:
  - |
    docker ps | grep -q nginx-proxy
    docker ps | grep -q nginx-ssl

install: skip
```
## Removing Cache 

I've made this bash script to remove cache, just run `chmod +x ./cache_remove.sh; ./cache_remove.sh`:

```bash
#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

echo "Cleaning /tmp and /var/tmp directories..."
find /tmp -type f -exec rm -f {} +
find /var/tmp -type f -exec rm -f {} +

echo "Cleaning APT cache..."
apt-get clean
```
