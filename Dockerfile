FROM centos:7

ARG NGINX_REPO=http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
ARG STATIC_SITE_REPO=https://github.com/daneden/animate.css.git
ARG STATIC_SITE_DIR=/animate.css
ARG V2RAY_INSTALL_URL=https://install.direct/go.sh

# RUN yum update -y
RUN rpm -ivh ${NGINX_REPO} \
    && yum install -y \
        epel-release \
        nginx \
        git \
    && git clone --single-branch --branch gh-pages --depth 1 ${STATIC_SITE_REPO} \
    && rm -rf ${STATIC_SITE_DIR}/.git \
    && mkdir -p /data \
    && mv ${STATIC_SITE_DIR} /data/www \
    && curl -L -s ${V2RAY_INSTALL_URL} | bash -s \
    && yum remove -y git \
    && yum clean all

COPY conf /conf

COPY run.sh /run.sh
RUN chmod 744 /run.sh

EXPOSE 443

ENTRYPOINT "/run.sh"
