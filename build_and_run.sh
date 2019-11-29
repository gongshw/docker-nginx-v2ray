#!/usr/bin/env bash

docker build -t docker-nginx-v2ray .

cert_dir=$(pwd)/cert
mkdir -p ${cert_dir}
docker run --rm --name docker-nginx-v2ray \
    -p 80:80 \
    -p 443:443 \
    -v "${cert_dir}":/data/cert \
    -e SITE_DOMAIN=localhost \
    -e V2RAY_TOKEN="00000000-0000-0000-0000-000000000000" \
    -e V2RAY_WS_PATH=/secret \
    docker-nginx-v2ray
