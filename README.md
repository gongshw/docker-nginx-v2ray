# docker 内部署 nginx + v2ray + ws + tls

![GitHub](https://img.shields.io/github/license/gongshw/docker-nginx-v2ray)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/gongshw/docker-nginx-v2ray)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/gongshw/docker-nginx-v2ray)


## 安装并启动 docker 服务

[Docker 文档](https://docs.docker.com/install/)

## 运行服务

```bash
#!/usr/bin/env bash

# 域名
SITE_DOMAIN=www.sample.com

# v2ray 的 client id
V2RAY_TOKEN=00000000-0000-0000-0000-000000000000

# v2ray ws 混淆的路径
V2RAY_WS_PATH=/secret/path

docker run -d --restart=always \
    --name docker-nginx-v2ray \
    -v /root/v2ray/cert:/data/cert \
    -p 80:80 \
    -p 443:443 \
    -e SITE_DOMAIN=${SITE_DOMAIN} \
    -e V2RAY_TOKEN=${V2RAY_TOKEN} \
    -e V2RAY_WS_PATH=${V2RAY_WS_PATH} \
    gongshw/docker-nginx-v2ray
```

访问 `https://${SITE_DOMAIN}`, 可以打开一个静态网站.

默认会在`./cert/${SITE_DOMAIN}` 下生成自签名的证书(`certificate.crt`)和私钥(`private.key`)文件.

为了安全, 建议用有效的证书替换.

## 文件挂载点

### /data/cert

证书文件, 如果不存在会自己生成. 路径如下:
```
/data/cert
└── ${SITE_DOMAIN}
    ├── certificate.crt      # pem 格式证书链
    └── private.key          # pem 格式私钥
```
建议用有效的证书替换.

### /data/www

伪装的静态站点. 

默认是 [https://github.com/daneden/animate.css/tree/gh-pages](https://daneden.github.io/animate.css/). 

可随意替换.

## 内部端口

### http/80

重定向请求到 `443` 端口.

### https/443

nginx 代理的 v2ray 服务, 伪装成了一个静态站点.

### vmess/12345

v2ray 的端口, 不建议直接对外暴露.
