#!/usr/bin/env bash

if [ -z "${SITE_DOMAIN}" ]; then
    echo "env SITE_DOMAIN not set!"
    exit 1
fi

if [ -z "${V2RAY_TOKEN}" ]; then
    echo "env V2RAY_TOKEN not set!"
    exit 1
fi

if [ -z "${V2RAY_WS_PATH}" ]; then
    echo "env V2RAY_WS_PATH not set!"
    exit 1
fi

echo "SITE DOMAIN          : ${SITE_DOMAIN}"
echo "V2RAY TOKEN          : ${V2RAY_TOKEN}"
echo "V2RAY WS PATH        : ${V2RAY_WS_PATH}"

DATA_DIR="/data"

CERTIFICATE_DIR="${DATA_DIR}/cert/${SITE_DOMAIN}"
CERTIFICATE_FILE="${CERTIFICATE_DIR}/certificate.crt"
CERTIFICATE_KEY_FILE="${CERTIFICATE_DIR}/private.key"
DHPARAM_FILE="${CERTIFICATE_DIR}/dhparam.pem"

V2RAY_PORT=12345

NGINX_DIR="/etc/nginx"
mkdir -p "${NGINX_DIR}/conf.d"
NGINX_CONF="${NGINX_DIR}/conf.d/default.conf"
V2RAY_CONF="${DATA_DIR}/v2ray/config.json"

start_v2ray() {
    echo "generating v2ray config to ${V2RAY_CONF}"
    mkdir -p "${DATA_DIR}/v2ray"
    sed \
        -e "s:\${V2RAY_PORT}:${V2RAY_PORT}:" \
        -e "s:\${V2RAY_TOKEN}:${V2RAY_TOKEN}:" \
        -e "s:\${V2RAY_WS_PATH}:${V2RAY_WS_PATH}:" \
        /conf/v2ray/config.json.template >${V2RAY_CONF}
    echo "starting v2ray at port ${V2RAY_PORT}"
    /usr/bin/v2ray -config ${V2RAY_CONF}
}

start_nginx() {
    echo "prepare certificate files for nginx"
    if [ -e "${CERTIFICATE_KEY_FILE}" ]; then
        echo "using exist certificate file ${CERTIFICATE_KEY_FILE}"
    else
        echo "generating a self-signed certificate (NOT SECURE!!!!!)"
        mkdir -p "${CERTIFICATE_DIR}"
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -out ${CERTIFICATE_FILE} \
            -keyout ${CERTIFICATE_KEY_FILE} \
            -subj "/C=US/ST=New York/L=New York/O=Global Security/OU=Global Security/CN=${SITE_DOMAIN}"
    fi


    echo "prepare dhparam file for nginx"
    if [ -e "${DHPARAM_FILE}" ]; then
        echo "using exist dhparam file ${DHPARAM_FILE}"
    else
        echo "generating 2048 bit dhparam file"
        openssl dhparam -out ${DHPARAM_FILE} 2048
    fi


    sed \
        -e "s:\${V2RAY_PORT}:${V2RAY_PORT}:" \
        -e "s:\${V2RAY_WS_PATH}:${V2RAY_WS_PATH}:" \
        -e "s:\${SITE_DOMAIN}:${SITE_DOMAIN}:" \
        -e "s:\${CERTIFICATE_FILE}:${CERTIFICATE_FILE}:" \
        -e "s:\${CERTIFICATE_KEY_FILE}:${CERTIFICATE_KEY_FILE}:" \
        -e "s:\${DHPARAM_FILE}:${DHPARAM_FILE}:" \
        /conf/nginx/site.conf.template >${NGINX_CONF}

    echo "starting nginx at port 80(http)&443(https)"
    mkdir -p /run/nginx
    nginx && echo "nginx started"
}

main() {
    start_nginx
    start_v2ray
}

main
